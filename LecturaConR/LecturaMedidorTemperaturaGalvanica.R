library(arduinor)
library(data.table)
library(tictoc)
library(ggplot2)
library(plotly)
con <- ar_init("/dev/ttyACM0", baud = 9600)  
theme_set(theme_minimal())


ProcesamientodeSenyal <- function(colecta.datos) {
  tic("Procesando señal")
  datos.procesados <- data.table(datos.crudos = colecta.datos )
  datos.procesados[, c("voltaje", "temperatura") := tstrsplit(datos.crudos, ",", fixed=TRUE)]
  datos.procesados[, voltaje := as.numeric(gsub("V: ", "", voltaje))]
  datos.procesados[, temperatura := as.numeric(gsub("C: |\\r\n", "", temperatura))]
  datos.procesados[, datos.crudos := NULL]
  datos.procesados[, tiempo := seq_along(voltaje)]
  toc()
  return(datos.procesados[])
}

ProbarViabilidad <- function(funcional = FALSE) {
  ar_flush_hard(con)
  dato.prueba <- ar_read(con)
  dato.prueba <- ProcesamientodeSenyal(dato.prueba)
  if(identical(dato.prueba, na.omit(dato.prueba))) {
    mensaje <- paste0(
      "Extracción exitosa los valores obtenidos son V:",
      dato.prueba$voltaje,
      " C: ",
      dato.prueba$temperatura
    )
    return(ifelse(funcional, TRUE, mensaje))
  } else {
    return(ifelse(funcional, FALSE, "Error en lectura de datos", mensaje))
  }
}

ExtraccionDatos <- function(intervalo.captura = 60, retraso = 10) {
  Sys.sleep(retraso)
  try(if(con < 0) stop("No existe conexión al puerto serial"))
  try(if(ProbarViabilidad(funcional = T) != TRUE) stop("Datos no validos"))
  tic("Inicio de captura de señal")
  datos.procesados <- ar_collect(con, size = intervalo.captura)
  datos.procesados <- ProcesamientodeSenyal(datos.procesados)
  toc()
  return(datos.procesados)
}

GraficaResultados <- function(datos.procesados, interactiva = FALSE) {
  if(interactiva){
    y1 <- list(
      tickfont = list(color = "rgb(205, 12, 24)"),
      side = "left",
      title = "Temperatura [°C]"
    )
    y2 <- list(
      tickfont = list(color = "rgb(22, 96, 167)"),
      overlaying = "y",
      side = "right",
      title = "Voltaje [Volts]"
    )
    plot_ly(datos.procesados, colors = c('blue', 'red')) %>%
      add_lines(
        x = ~tiempo,
        y = ~temperatura,
        name = "Temperatura [°C]",
        text = ~paste('Tiempo: ', tiempo, ' segs.<br> Temperatura: ', temperatura, ' °C'),
        hoverinfo = 'text',
        line = list(color = 'rgb(205, 12, 24)', width = 4)
      ) %>%
      add_lines(
        x = ~tiempo,
        y = ~voltaje,
        name = "Voltaje [Volts]",
        yaxis = "y2",
        text = ~paste('Tiempo: ', tiempo, ' segs. <br> Voltaje: ', voltaje, ' Volts'),
        hoverinfo = 'text',
        line = list(color = 'rgb(22, 96, 167)', width = 4)
      ) %>%
      layout(
        yaxis2 = y2,
        xaxis = list(title= "Tiempo [seg]"),
        yaxis = y1,
        legend = list(x = 100, y = 0.9)
      )
  } else {
    p <- ggplot(datos.procesados) +
      geom_line(aes(x = tiempo, y = temperatura), colour = "#CD0C18") +
      geom_line(aes(x = tiempo, y = voltaje * 10), colour = "#1660A7") +
      scale_y_continuous(sec.axis = sec_axis(~./10, name = "Voltaje [Volts]")) +
      labs(y = "Temperatura [°C]", x = "Tiempo [seg]")
    return(p)
  }
}
