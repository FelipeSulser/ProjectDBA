CREATE OR REPLACE
PACKAGE BODY ESTADISTICAS_ALU AS

   PROCEDURE MAS_FALLOS AS
   ERROR_CURSOR_ABIERTO exception;
   ejer_id docencia.ejercicio.ejercicio_id%type;
   ejercicio_enunciado docencia.ejercicio.enunciado%type;
   ejercicio_fallos docencia.ejercicio.fallos%type;
   CURSOR ejer_cur is -- Cursor que tiene los ejercicios donde más se ha fallado (todos tienen el mismo nº de fallos)
       select ejercicio_id,enunciado,fallos from docencia.ejercicio
       where fallos in (select max(fallos) from docencia.ejercicio);
       
    BEGIN
       OPEN ejer_cur;
       LOOP
          FETCH ejer_cur into ejer_id, ejercicio_enunciado,ejercicio_fallos;
          EXIT WHEN ejer_cur%notfound;
          dbms_output.put_line('ID= '||ejer_id || ' ' || ejercicio_enunciado || ' #Fallos=' ||ejercicio_fallos);
       END LOOP;
       CLOSE ejer_cur;
       
       IF ejer_cur%ISOPEN = TRUE THEN 
       RAISE ERROR_CURSOR_ABIERTO;
       END IF;
       
       EXCEPTION
       WHEN ERROR_CURSOR_ABIERTO then CLOSE ejer_cur;
       WHEN others then
       dbms_output.put_line('Error, no se ha podido encontrar los ejercicios');
  END MAS_FALLOS;


END ESTADISTICAS_ALU;