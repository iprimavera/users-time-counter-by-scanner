#!/bin/bash

#TODO al final del dia enviar un correo con sus horas

if [ ! -f .last_time_exec.txt ]; then
  echo 00000000 > .last_time_exec.txt
fi
if [ ! -f gecos.csv ]; then
  touch gecos.csv
fi
if [ ! -f data.csv ]; then
  echo "dia" > data.csv
  if [ -s gecos.csv ]; then
    while read line; do
      sed -i "1s/$/,$line/" data.csv
    done <<< $(cat gecos.csv | cut -d, -f1) 
  fi
fi
if [ ! -f .registro_tmp.csv ]; then
  touch .registro_tmp.csv
fi

if [ $(cat .last_time_exec.txt) -lt $(date +%Y%m%d) ]; then
  echo $(date +%Y%m%d) > .last_time_exec.txt
  rm .registro_tmp.csv
  touch .registro_tmp.csv
  
  echo $(date +%F) >> data.csv

  for i in $(seq 1 $(cat gecos.csv | wc -l)); do
    sed -i "/$(date +%F)/s/$/,0h0m0s/" data.csv
  done
  
  if [ -s gecos.csv ]; then
    while read line; do
      echo "$line,desconectado,0" >> .registro_tmp.csv
    done <<< $(cat gecos.csv | cut -d, -f1) 
  fi
fi

while true; do
  
  read codigo
  clear
  
  #TODO no se por que da un error
  if [ -z $(cat gecos.csv | grep $codigo) ] 2>/dev/null; then 
    confirmacion="n"
    tput setaf 4; echo "Parece que eres nuevo en el sistema."; tput sgr0
    until [ $confirmacion = "y" ]; do
      tput setaf 2; echo -n "Indica tu nombre completo: "; tput sgr0
      read nombre
      tput setaf 2; echo -n "Indica tu correo electronico: "; tput sgr0
      read correo
      clear
      tput setaf 3
      echo " *** Esta informacion es correcta?:"
      echo "     Nombre completo: $nombre"
      echo "     Correo electronico: $correo"; tput sgr0
      echo ""
      echo -n " [y/n]: "
      read -n1 confirmacion
      clear
    done
    echo "$codigo,$nombre,$correo" >> gecos.csv
    echo "$codigo,desconectado,0" >> .registro_tmp.csv
    sed -i "1s/$/,$codigo/" data.csv 
    sed -i "/$(date +%F)/s/$/,0h0m0s/" data.csv
    tput setaf 1; echo "Actualmente estas desconectado, vuelve a pasar tu codigo si quieres empezar a cotizar"; tput sgr0
    continue
  else
    nombre=$(cat gecos.csv | grep $codigo | cut -d, -f2)
    correo=$(cat gecos.csv | grep $codigo | cut -d, -f3)
  fi
  
  tiempo_actual=$(date +%H%M%S)
  tiempo_ultimo=$(cat .registro_tmp.csv | grep $codigo | cut -d, -f3)
  
  numero=0
  for i in horas minutos segundos; do
    for j in actual ultimo; do
      eval "${i}_${j}=\"\${tiempo_${j}:${numero}:2}\""
    done
    numero=$((numero+2))
  done

  if [ $(cat .registro_tmp.csv | grep $codigo | cut -d, -f2) = "desconectado" ]; then
    
    # AL CONECTARSE
    
    tput setaf 2; echo "Bienvenid@  $(echo $nombre | cut -d" " -f-2)!"; tput sgr0
    sed -i "/$codigo/s/desconectado,$tiempo_ultimo/conectado,$tiempo_actual/" .registro_tmp.csv
  
  else

    # AL DESCONECTARSE
    
    trabajado_horas=$((10#$horas_actual-10#$horas_ultimo)) # el 10# es para que sean base 10
    trabajado_minutos=$((10#$minutos_actual-10#$minutos_ultimo))
    trabajado_segundos=$((10#$segundos_actual-10#$segundos_ultimo))

    if [ $trabajado_segundos -lt 0 ]; then
      trabajado_minutos=$((trabajado_minutos-1))
      trabajado_segundos=$((60-(-trabajado_segundos)))
    fi
    if [ $trabajado_minutos -lt 0 ]; then
      trabajado_horas=$((trabajado_horas-1))
      trabajado_minutos=$((60-(-trabajado_minutos)))
    fi

    ya_trabajado=$(awk -F"," -v linea="$(date +%F)" -v columna="$codigo" '
    NR==1 {
      for(i=1; i<=NF; i++){
        if($i == columna){
          numerocolumna = i
          break
        }
      }
      next
    }
    {
      if($1 == linea) {
        print $numerocolumna
      }
    }' data.csv)
    
    ya_trabajado_horas=$(echo $ya_trabajado | cut -d"h" -f1)
    ya_trabajado_minutos=$(echo $ya_trabajado | cut -d"m" -f1 | cut -d"h" -f2)
    ya_trabajado_segundos=$(echo $ya_trabajado | cut -d"s" -f1 | cut -d"m" -f2)

    for i in horas minutos segundos; do
      eval "trabajado_${i}=\$((trabajado_${i}+ya_trabajado_${i}))"
    done

    if [ $trabajado_segundos -gt 59 ]; then
      trabajado_minutos=$((trabajado_minutos+1))
      trabajado_segundos=$((trabajado_segundos-60))
    fi
    if [ $trabajado_minutos -gt 59 ]; then
      trabajado_horas=$((trabajado_horas+1))
      trabajado_minutos=$((trabajado_minutos-60))
    fi

    total="${trabajado_horas}h${trabajado_minutos}m${trabajado_segundos}s"

    gawk -i inplace -F"," -v linea="$(date +%F)" -v columna="$codigo" -v total="$total" '
    BEGIN {
      OFS=","
    }
    NR==1 {
      for(i=1; i<=NF; i++){
        if($i == columna){
          numerocolumna = i
          break
        }
      }
      print $0
      next
    }
    {
      if($1 == linea) {
        $numerocolumna = total
      }
      print $0
    }' data.csv

    tput setaf 1; echo "Hasta luego $(echo $nombre | cut -d" " -f-2)!"; tput sgr0
    sed -i "/$codigo/s/conectado,$tiempo_ultimo/desconectado,$tiempo_actual/" .registro_tmp.csv

  fi
  
  #cat *.csv
  #cat .*.csv
  #cat .*.txt

done

exit 0
