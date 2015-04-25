ALTER TABLE matricula
DROP CONSTRAINT MATRICULA_USUARIO_FK;

alter table matricula
ADD CONSTRAINT MATRICULA_USUARIO_FK
FOREIGN KEY (USUARIO_USUARIO_ID)
REFERENCES USUARIO(usuario_id)
ON DELETE CASCADE;