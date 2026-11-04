namespace GatoAPI.Modelos
{
    public class HistorialPartidas
    {
        public int IdHistorial { get; set; }
        public int IdPartida { get; set; }

        public int Posicion { get; set; }

        public DateTime Fecha_Movimiento { get; set; }

        //Campos de auditoria
        public DateTime Fecha_Creacion { get; set; } = DateTime.Now;
        public string? Usuario_Creacion { get; set; }
        public DateTime? Fecha_Modificacion { get; set; }
        public string? Usuario_Modificacion { get; set; }
    }
}
