using GatoAPI.Modelos;
using Microsoft.EntityFrameworkCore;

namespace GatoAPI
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Partidas> Partidas { get; set; }
        public DbSet<HistorialPartidas> HistorialPartidas { get; set; } 

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Partidas>().ToTable("Partidas");
            modelBuilder.Entity<HistorialPartidas>().ToTable("HistorialPartidas");
        }
    }
}
