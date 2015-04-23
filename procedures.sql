create or replace 
PACKAGE BODY GEST_USUARIO AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
 PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2) IS 
  ERROR_PRIVS_INSUF exception;
  ERROR_USUARIO_EXISTE exception;
  ERROR_DESCONOCIDO exception;
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'CREATE USER ' || usuario || ' IDENTIFIED BY ' || pass;
      DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' creado correctamente');
      EXCEPTION WHEN OTHERS THEN 
      IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    END;
    
    exception
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    when ERROR_USUARIO_EXISTE then dbms_output.put_line('Error: el usuario ' || usuario || ' ya existe');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
  END CREAR_USUARIO;
 
PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2) IS
  ERROR_PRIVS_INSUF exception;
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_DESCONOCIDO exception;
  
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
      SYS.dbms_output.put_line('Usuario ' || usuario || ' borrado correctamente');  
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1918 THEN RAISE ERROR_USUARIO_NO_EXISTE;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    EXCEPTION
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    when ERROR_USUARIO_NO_EXISTE then dbms_output.put_line('Error: el usuario ' || usuario || ' no existe');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
  END BORRAR_USUARIO;
  
  -- Borra todos los usuarios buscando en la tabla usuarios los usuarios y llamando
  -- a la función BORRAR_USUARIO(usuario) en un for.
  
  PROCEDURE BORRAR_TODOS_USUARIOS IS
  cursor c_usuarios IS SELECT nombre FROM usuario;
  BEGIN
    FOR var_usuario in c_usuarios LOOP -- Puedo declarar la variable var_usuario aquí.
      BORRAR_USUARIO(var_usuario.nombre);
    END LOOP;
    EXCEPTION 
      WHEN no_data_found THEN
        dbms_output.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        dbms_output.put_line('Error desconocido.');
  END BORRAR_TODOS_USUARIOS;
  
  PROCEDURE BLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
      SYS.dbms_output.put_line('Usuario ' || usuario || ' bloqueado correctamente');
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    EXCEPTION
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('Error, el usuario '|| usuario ||' no existe.');
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error, no se tienen privilegios suficientes.');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido.');
  END BLOQUEAR_USUARIO;

  PROCEDURE BLOQUEAR_TODOS_USUARIOS IS
  cursor c_usuarios IS SELECT nombre FROM usuario; -- Cursor que almacena los nombres de los usuarios
  BEGIN
    FOR var_usuario IN c_usuarios LOOP -- Puedo declarar la variable var_usuario aquí.
      BLOQUEAR_USUARIO(var_usuario.nombre); -- Bloqueamos cada usuario
    END LOOP;
    EXCEPTION
      WHEN no_data_found THEN -- Si no hay usuarios (consulta vacía)
        dbms_output.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        dbms_output.put_line('Error desconocido.');
  END BLOQUEAR_TODOS_USUARIOS;
  
  PROCEDURE DESBLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT UNLOCK';
      SYS.dbms_output.put_line('Usuario ' || usuario || ' desbloqueado correctamente');
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    EXCEPTION
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('Error, el usuario '|| usuario ||' no existe.');
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error, no se tienen privilegios suficientes.');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido.');
  END DESBLOQUEAR_USUARIO;

  PROCEDURE DESBLOQUEAR_TODOS_USUARIOS IS
  cursor c_usuarios IS SELECT nombre FROM usuario; -- Cursor que almacena los nombres de los usuarios
  BEGIN
    FOR var_usuario IN c_usuarios LOOP -- Puedo declarar la variable var_usuario aquí.
      DESBLOQUEAR_USUARIO(var_usuario.nombre); -- Bloqueamos cada usuario
    END LOOP;
    EXCEPTION
      WHEN no_data_found THEN -- Si no hay usuarios (consulta vacía)
        dbms_output.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        dbms_output.put_line('Error desconocido.');
  END DESBLOQUEAR_TODOS_USUARIOS;
  
  -- Mata la sesión de usuario. Si no la tiene iniciada, nos dice que ese usuario no tiene iniciada la sesión
  -- Hemos creado un sinónimo público para V$session llamado v_$session y hemos dado permiso de select a él a R_profesor y docencia.
  --
  PROCEDURE MATAR_SESION (usuario IN VARCHAR2) IS
  
  VAR_SID v_$session.sid%TYPE;
  VAR_SERIAL# v_$session.serial#%TYPE;
  ERROR_USUARIO_NO_EXISTE exception;
  
  BEGIN
    BEGIN
      select sid into VAR_SID from v_$session where username = usuario;
      select serial# into VAR_SERIAL# from v_$session where username = usuario;
      exception when no_data_found then
      raise ERROR_USUARIO_NO_EXISTE;
      --DBMS_OUTPUT.put_line('alter system kill session '||''''||VAR_SID||','||VAR_SERIAL#|| '#'|| '''');
    END;
  BEGIN
    EXECUTE IMMEDIATE 'alter system kill session '''||VAR_SID||','||VAR_SERIAL#||''' ';
    exception when others then DBMS_OUTPUT.put_line('Error al matar sesión.');
  END;  
  
  exception
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('El usuario '||usuario||' no tiene la sesión iniciada.');
    when others then DBMS_OUTPUT.put_line('Error desconocido.');
  
  END MATAR_SESION;
  

END GEST_USUARIO;
