using GatoAPI.Modelos;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace GatoAPI.Repositorios
{
    public class PartidaRepository
    {
        private readonly AppDbContext _context;

        public PartidaRepository(AppDbContext context)
        {
            _context = context;
        }

        //Create 
        public async Task CrearPartidas(Partidas p)
        { 
            var parameters = new[]{ new SqlParameter("@JugadorActual", p.JugadorActual),
                                    new SqlParameter("@Estado", p.Estado),
                                    new SqlParameter("@Usuario", p.Usuario_Creacion) };

            await _context.Database.ExecuteSqlRawAsync("EXEC sp_CrearPartida @JugadorActual, @Estado, @Usuario", parameters);

        }
        //Read 
        public async Task<List<Partidas>> LeerPartidas()
        {
            return await _context.Partidas.ToListAsync();
        }

        //Update
        public async Task Actualizar(Partidas p)
        { 
            var parametros = new[]
            {
                new SqlParameter("@idPartida", p.IdPartida),
                new SqlParameter("@jugadorActual", p.JugadorActual),
                new SqlParameter("@estado", p.Estado),
                new SqlParameter("@usuario_modificacion", p.Usuario_Modificacion)
            };
            await _context.Database.ExecuteSqlRawAsync("EXEC sp_ActualizarPartida @idPartida,@jugadorActual,@estado, @usuario_modificacion ", parametros);
        }
        //Delete 
        public async Task Eliminar(int id)
        {
            var parametro = new SqlParameter("@idPartida", id);
            await _context.Database.ExecuteSqlRawAsync("EXEC SP_ELIMINAR_PARTIDA @idPartida", parametro);
        }

    }
}
