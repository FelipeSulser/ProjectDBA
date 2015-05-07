create or replace 
PACKAGE BODY ESTADISTICAS_ALU AS

  procedure MAS_FALLOS AS
   ejer_id ejercicio.ejercicio_id%type;
   ejercicio_enunciado ejercicio.enunciado%type;
   ejercicio_fallos ejercicio.fallos%type;
   CURSOR ejer_cur is 
       select ejercicio_id,enunciado,fallos from ejercicio
       where fallos in (select max(fallos) from ejercicio);
    BEGIN  
       OPEN ejer_cur;
       LOOP
          FETCH ejer_cur into ejer_id, ejercicio_enunciado,ejercicio_fallos;
          EXIT WHEN ejer_cur%notfound;
          dbms_output.put_line('ID= '||ejer_id || ' ' || ejercicio_enunciado || ' #Fallos=' ||ejercicio_fallos);
       END LOOP;
       CLOSE ejer_cur;
       
       EXCEPTION
       when others then
       dbms_output.put_line('Error, no se ha podido encontrar los ejercicios');
  END MAS_FALLOS;
  
  
  /**
  Dada una relacion, halla el minimo tiempo y si el alumno 
  ha realizado la relacion en menos tiempo .
  Muestra esa información
  
  */
  procedure antiplagio_relacion(relacion_id in number) as
    
   dedic_tiempo_dias number;
   dedic_tiempo_horas number;
   dedic_tiempo_minutos number;
   dedic_tiempo_segundos number;
   fecha_inicio_al docencia.audit_ejer.fecha_inicio%type;
   fecha_fin_al docencia.audit_ejer.fecha_entrega_correcto%type;
 
   alu_usuario_id docencia.relacion.usuario_usuario_id%type;
  
    suma_total_min number;
    
    tiempo_min number;
     excepcion_no_tiempo_minimo exception; 
    excepcion_rel_no_terminada exception;
  CURSOR alum_rel(p_alu_usuario  number)  is
    select docencia.audit_ejer.fecha_inicio, docencia.audit_ejer.fecha_entrega_correcto from docencia.audit_ejer
    inner join 
    (select docencia.calif_ejercicio.ejercicio_ejercicio_id, docencia.calif_ejercicio.relacion_relacion_id 
    from docencia.calif_ejercicio where docencia.calif_ejercicio.usuario_usuario_id = p_alu_usuario and docencia.calif_ejercicio.relacion_relacion_id = relacion_id) t2 
    on docencia.audit_ejer.ejercicio_id = t2.ejercicio_ejercicio_id 
    where docencia.audit_ejer.usuario_id = p_alu_usuario and docencia.audit_ejer.fecha_entrega_correcto is not null;
   BEGIN
   begin
   select usuario_usuario_id into alu_usuario_id  from relacion ;
   select tiempo_minimo
   into tiempo_min 
   from relacion
   where relacion.relacion_id = relacion_id;
   exception
   when others then
   raise excepcion_no_tiempo_minimo;
   end;
    dedic_tiempo_dias := 0;
    dedic_tiempo_horas := 0;
    dedic_tiempo_minutos := 0;
    dedic_tiempo_segundos := 0;
    
    suma_total_min := 0;
    
      FOR calif IN alum_rel(alu_usuario_id) LOOP
      begin
      dedic_tiempo_dias := dedic_tiempo_dias + extract(day from (calif.fecha_inicio - calif.fecha_entrega_correcto)); 
      dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from (calif.fecha_inicio - calif.fecha_entrega_correcto));
      dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from (calif.fecha_inicio - calif.fecha_entrega_correcto));
      dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from (calif.fecha_inicio - calif.fecha_entrega_correcto));
      exception
      when others then 
      raise excepcion_rel_no_terminada;
      END;
    END LOOP;
    /*
    OPEN alum_rel;
    LOOP
      FETCH alum_rel into fecha_inicio_al, fecha_fin_al;
      EXIT WHEN alum_rel%notfound;
      dedic_tiempo_dias := dedic_tiempo_dias + extract(day from (fecha_fin_al - fecha_inicio_al)); 
      dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from (fecha_fin_al - fecha_inicio_al));
      dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from (fecha_fin_al - fecha_inicio_al));
      dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from (fecha_fin_al - fecha_inicio_al));
      DBMS_OUTPUT.PUT_LINE(fecha_inicio_al || '   '  || fecha_fin_al);
    END LOOP;
    */
    
  IF alum_rel%ISOPEN = TRUE THEN 
    CLOSE alum_rel;
  END IF;
  
  suma_total_min := dedic_tiempo_dias*24*60+
                    dedic_tiempo_horas*60+
                    dedic_tiempo_minutos+
                    dedic_tiempo_segundos/60;
  if suma_total_min <= tiempo_min
  then
  dbms_output.put_line('WARNING!! Usuario #'||alu_usuario_id||' ha realizado la relación '||relacion_id|| ' en '||suma_total_min);
  
  
  end if;
     
  exception
  when excepcion_no_tiempo_minimo
  then
  dbms_output.put_line('No se ha introducido un tiempo minimo para la relacion '||relacion_id||'!!');
  when excepcion_rel_no_terminada
  then
  dbms_output.put_line('El alumno aun no ha acabado la relacion o no ha empezado!!');
  when others then
  dbms_output.put_line('Error desconocido');
    IF alum_rel%ISOPEN = TRUE THEN 
    CLOSE alum_rel;
  END IF;
    end antiplagio_relacion;



  --Igual que la anterior pero muestra el antiplagio de todas las relaciones
  procedure antiplagio_relacion_todas as
  cursor rel_cur is
  select relacion_id from relacion
  ;
  
  begin
   FOR calif IN rel_cur LOOP
      
      antiplagio_relacion(calif.relacion_id);
     
    END LOOP;
    exception
    when others then
    dbms_output.put_line('Error, no se ha podido ejecutar');
     IF rel_cur%ISOPEN = TRUE THEN 
    CLOSE rel_cur;
    end if;
  end antiplagio_relacion_todas;


END ESTADISTICAS_ALU;