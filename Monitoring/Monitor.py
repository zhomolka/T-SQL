import pyodbc
import pandas as pd

# Vaše konfigurační údaje (ponechávám strukturu)
conn_str = (
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    r'SERVER=localhost;'  # Pravděpodobně váš Docker kontejner
    r'DATABASE=MonitorDB;'
    r'UID=sa;'            # Výchozí uživatel pro SQL Server
    r'PWD=DockerSql2026!'     
)

sql_query = "SELECT TOP (1000) [MonitorId], [DisplayName], [Command] FROM [MonitorDB].[dbo].[Monitor]"

try:
    # Připojení pomocí kontextového manažeru (automaticky zavře spojení)
    with pyodbc.connect(conn_str) as conn:
        # Pandas načte data a automaticky doplní názvy sloupců z DB
        df = pd.read_sql(sql_query, conn)

    # 1. Zobrazení v konzoli (pro rychlou kontrolu)
    print(df.head()) 

    # 2. Generování kompletního HTML kódu tabulky
    # 'table-striped' je CSS třída, pokud používáte Bootstrap
    html_table = df.to_html(classes='table table-striped', index=False)
    
    # Uložení do souboru pro náhled v prohlížeči
    with open("vystup.html", "w", encoding="utf-8") as f:
        f.write(html_table)
    
    print("\nTabulka byla vygenerována do souboru vystup.html")

except Exception as e:
    print(f"Chyba: {e}")