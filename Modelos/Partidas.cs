namespace GatoAPI.Modelos
{
    public class Partidas
    {
        public int IdPartida { get; set; }
         
        public string JugadorActual { get; set; } = "X";

        public string Estado { get; set; } = "A";

        public string? Ganador { get; set; }

        public DateTime? Fecha_Finalizacion { get; set; }

        //Campos de auditoria
        public DateTime Fecha_Creacion { get; set; } = DateTime.Now;

        public string? Usuario_Creacion { get; set; }

        public DateTime? Fecha_Modificacion { get; set; }

        public string? Usuario_Modificacion { get; set; }
    }
}
