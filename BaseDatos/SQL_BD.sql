create database JuegoGatoDB; 
go
use JuegoGatoDB;
go
create table Partidas (
	idPartida int identity(1,1) primary key,
	jugadorActual char(1) default 'X', --X o O
	estado char(1) default 'A', -- A: Activa P:Pausada T: Terminada
	ganador char(1), -- para indicar quien gano la partida
	fecha_finalizacion datetime, 
	fecha_creacion datetime default GETDATE(), 
	usuario_creacion varchar(25),
	fecha_modificacion datetime,
	usuario_modificacion varchar(25)
);
go
create table HistorialPartidas (
	idHistorial int identity(1,1) primary key, 
	idPartida int foreign key references Partidas(idPartida), 
	posicion int, -- 0,1,2,3,4,5,6,7,8,9
	fecha_movimiento datetime, 
	fecha_creacion datetime default GETDATE(), 
	usuario_creacion varchar(25),
	fecha_modificacion datetime,
	usuario_modificacion varchar(25)
);
go

--FRANCISCO -> procedimiento crear partida 
CREATE OR ALTER PROCEDURE sp_CrearPartida 
    @JugadorActual CHAR(1),
    @Estado CHAR(1),
    @Usuario VARCHAR(25)
AS
BEGIN
    IF @JugadorActual IS NULL OR UPPER(@JugadorActual) NOT IN ('X', 'O')
    BEGIN
        RAISERROR('El valor del jugador debe ser X o O', 16, 1);
        RETURN;
    END;
 
    IF @Estado IS NULL OR UPPER(@Estado) NOT IN ('A', 'P', 'T')
    BEGIN
        RAISERROR('El valor del estado debe ser A, P o T', 16, 1);
        RETURN;
    END;
 
    IF @Usuario IS NULL
    BEGIN
        RAISERROR('El usuario es obligatorio', 16, 1);
        RETURN;
    END;
    INSERT INTO Partidas (jugadorActual, estado, usuario_creacion)
    VALUES (UPPER(@JugadorActual), UPPER(@Estado), @Usuario)
END;
GO
--ALBERTH  -> procedimiento actualizar partida
CREATE OR ALTER PROCEDURE sp_ActualizarPartida
    @idPartida INT,
    @jugadorActual CHAR(1),
    @estado CHAR(1),
    @usuario_modificacion VARCHAR(25)
AS
BEGIN
    SET NOCOUNT ON;
 
    -- CONVERTIR LOS VALORES A MAYUSCULAS
    SET @jugadorActual = UPPER(@jugadorActual);
    SET @estado = UPPER(@estado);
 
    -- VALIDAR QUE LA PARTIDA EXISTA
    IF NOT EXISTS (
        SELECT 1
        FROM Partidas
        WHERE idPartida = @idPartida
    )
    BEGIN
        RAISERROR('La partida no existe.', 16, 1);
        RETURN;
    END;
 
    -- VALIDAR JUGADOR ACTUAL
    IF @jugadorActual IS NULL
       OR @jugadorActual NOT IN ('X', 'O')
    BEGIN
        RAISERROR('El jugador debe ser X u O.', 16, 1);
        RETURN;
    END;
 
    -- VALIDAR ESTADO DE LA PARTIDA
    IF @estado IS NULL
       OR @estado NOT IN ('A', 'P', 'T')
    BEGIN
        RAISERROR('Estado no valido. Debe ser A, P o T.', 16, 1);
        RETURN;
    END;
 
    -- ACTUALIZAR PARTIDA
    UPDATE Partidas
    SET
        jugadorActual = @jugadorActual,
        estado = @estado,
        fecha_finalizacion =
            CASE
                WHEN @estado = 'T' THEN GETDATE()
                ELSE NULL
            END,
        fecha_modificacion = GETDATE(),
        usuario_modificacion = @usuario_modificacion
    WHERE idPartida = @idPartida;
 
    PRINT 'Partida actualizada correctamente.';
 
END;
GO 

--AXEL RAMON -> procedimiento seleccionar partidas
create procedure sp_SeleccionarPartidas
as
begin
    set nocount on;
 
    begin try
        select idPartida,
               jugadorActual,
               estado,
               ganador,
               fecha_finalizacion,
               fecha_creacion,
               usuario_creacion,
               fecha_modificacion,
               usuario_modificacion
        from Partidas;
    end try
    begin catch
        -- Manejo de errores
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        declare @ErrorSeverity int = ERROR_SEVERITY();
        declare @ErrorState int = ERROR_STATE();
 
        raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end;
go

--MARÍA CELESTE -> procedimiento eliminar partida
CREATE PROCEDURE [dbo].[SP_ELIMINAR_PARTIDA]
    @idPartida      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Verificamos si la partida existe
        IF EXISTS (SELECT 1 FROM Partidas WHERE idPartida = @idPartida)
        BEGIN
            BEGIN TRANSACTION;
            -- Primero eliminamos el historial (por la llave foránea)
            DELETE FROM HistorialPartidas
            WHERE idPartida = @idPartida;
            -- Luego eliminamos la partida
            DELETE FROM Partidas
            WHERE idPartida = @idPartida;
            COMMIT TRANSACTION;
            -- Retornamos el ID de la partida eliminada
            SELECT @idPartida AS idPartida;
        END
        ELSE
        BEGIN
            -- Si no existe, lanzamos un error
            RAISERROR ('La partida indicada no existe.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- Si hay una transacción abierta, la deshacemos
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
--SEBASTIAN -> procedimiento crear historial
CREATE PROCEDURE [dbo].[SP_CrearHistorial]
    @idPartida INT,
    @posicion INT
AS
BEGIN
    SET NOCOUNT ON;
 
    BEGIN TRY
        INSERT INTO HistorialPartidas (
            idPartida,
            posicion,
            fecha_movimiento
        )
        VALUES (
            @idPartida,
            @posicion,
            GETDATE()
        );
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
 
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

--ALONSO ALEJANDRO -> procedimiento actualizar historial
CREATE PROCEDURE [dbo].[sp_ActualizarHistorial]
    @idHistorial          INT,
    @posicion             INT,
    @usuario_modificacion VARCHAR(25)
AS
BEGIN
    SET NOCOUNT ON;
 
    BEGIN TRY
        -- Excepcion 1: el registro no existe
        IF NOT EXISTS (SELECT 1 FROM HistorialPartidas WHERE idHistorial = @idHistorial)
        BEGIN
            THROW 50001, 'El registro del historial no existe.', 1;
        END
 
        -- Excepcion 2: la posicion no es valida
        IF @posicion < 0 OR @posicion > 8
        BEGIN
            THROW 50002, 'La posicion debe estar entre 0 y 8.', 1;
        END
 
        -- Actualizamos
        UPDATE HistorialPartidas
        SET posicion = @posicion,
            fecha_modificacion = GETDATE(),
            usuario_modificacion = @usuario_modificacion
        WHERE idHistorial = @idHistorial;
 
        -- Retornamos el ID del registro actualizado
        SELECT @idHistorial AS idHistorial;
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
 
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
go
--MARCO -> procedimiento seleccionar historial
CREATE OR ALTER PROCEDURE sp_SeleccionarHistorial
AS
BEGIN
    SET NOCOUNT ON;
 
    SELECT
        H.idHistorial,
        H.idPartida,
        P.jugadorActual,
        P.estado,
        P.ganador,
        H.posicion,
        H.fecha_movimiento,
        H.fecha_creacion,
        H.usuario_creacion,
        H.fecha_modificacion,
        H.usuario_modificacion
    FROM HistorialPartidas AS H
    INNER JOIN Partidas AS P
        ON H.idPartida = P.idPartida
    ORDER BY H.fecha_movimiento DESC, H.idHistorial DESC;
END;
GO

--MORALES ROMERO ISAAC ->procedimiento eliminar historial 
CREATE OR ALTER PROCEDURE dbo.SP_ELIMINAR_HISTORIAL
   @idHistorial INT
AS
BEGIN
   SET NOCOUNT ON;
 
   BEGIN TRY
       IF NOT EXISTS (
           SELECT 1
           FROM dbo.HistorialPartidas
           WHERE idHistorial = @idHistorial
       )
       BEGIN
           RAISERROR(
               'El historial indicado no existe.',
               16,
               1
           );
           RETURN;
       END;
 
       DELETE FROM dbo.HistorialPartidas
       WHERE idHistorial = @idHistorial;
 
       SELECT
           @idHistorial AS idHistorial,
           'Historial eliminado correctamente.' AS Mensaje;
   END TRY
   BEGIN CATCH
       DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
       DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
       DECLARE @ErrorState INT = ERROR_STATE();
 
       RAISERROR(
           @ErrorMessage,
           @ErrorSeverity,
           @ErrorState
       );
   END CATCH
END;
GO



