CREATE PUBLIC SYNONYM mis_datos
FOR docencia.mis_datos;
GRANT SELECT ON mis_datos TO R_alumno;

CREATE PUBLIC SYNONYM mis_notas
FOR docencia.mis_notas;
GRANT SELECT ON mis_notas TO R_alumno;

CREATE PUBLIC SYNONYM mis_notas_de_ejercicios
FOR docencia.mis_notas_de_ejercicios;
GRANT SELECT ON mis_notas_de_ejercicios TO R_alumno;

CREATE PUBLIC SYNONYM notas_alumnos
FOR docencia.notas_alumnos;
GRANT SELECT ON notas_alumnos TO r_administrativo;


create public synonym v_$session for v_$session;