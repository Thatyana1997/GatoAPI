using GatoAPI.Modelos;
using GatoAPI.Repositorios;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Mvc;
using RouteAttribute = Microsoft.AspNetCore.Mvc.RouteAttribute;

namespace GatoAPI.Controladores
{
    [Route("api/[controller]")]
    [ApiController]
    public class PartidaController : ControllerBase
    {
        private readonly PartidaRepository _repository;

        public PartidaController(PartidaRepository repository)
        {
            _repository = repository;
        }
        //Create
        [HttpPost]
        public async Task<IActionResult> CrearPartida([FromBody] Partidas partida)
        {
            await _repository.CrearPartidas(partida);
            return Ok(new
            {
                message = "Partida creada de forma exitosa!"
            });
        }
        //Read
        [HttpGet]
        public async Task<ActionResult<List<Partidas>>> LeerTodasPartidas()
        {
            return await _repository.LeerPartidas();
        }

        //Update
        [HttpPut("{id}")]
        public async Task<IActionResult> ActualizarPartida(int id, [FromBody] Partidas partida)
        {
            if (id != partida.IdPartida)
            {
                return BadRequest();
            }
            else
            {
                await _repository.Actualizar(partida);
                return NoContent();
            }
        }

        //Delete 
        [HttpDelete("{id}")]
        public async Task<IActionResult> EliminarPartida(int id)
        { 
            await _repository.Eliminar(id);
            return NoContent();

        }

    }
}
