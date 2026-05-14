import pyodbc
import time
import pandas as pd
import os
import webbrowser

# 1. Konfigurace - Přidáno TrustServerCertificate pro SSMS 19/20
conn_str = (
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    r'SERVER=localhost;'
    r'DATABASE=MonitorDB;'
    r'UID=sa;'
    r'PWD=DockerSql2026!;'
    r'TrustServerCertificate=yes;' 
)

sql_query = "SELECT TOP (1000) [DisplayName], [Command],[ExecDuration],[RepeatAfterMin],[RunFromHour],[RunToHour],[Inform1],[Inform2],[Inform3],[LastRunTime],[LastMessTime],[LastMessage],[InformBySecondMatch],[ReparationProc],[Note] FROM [MonitorDB].[dbo].[Monitor]"

# Cesta k výstupu - zajistí vytvoření ve stejné složce jako skript
output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Vystup.html")

def highlight_long_duration(val):
    if isinstance(val, (int, float)) and val > 60:
        return 'background-color: yellow'
    return ''

print("Monitor spuštěn...")

try:
    while True:
        # 1. Načtení dat
        with pyodbc.connect(conn_str) as conn:
            df = pd.read_sql(sql_query, conn)

        # 2. Styling (volitelné, pokud ho chceš v HTML použít)
        # Pro zjednodušení teď v šabloně používáme základní df.to_html

        # 3. Definice HTML šablony
        html_template = f"""
        <!DOCTYPE html>
        <html lang="cs">
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="refresh" content="30">
            <title>MonitorDB Status</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css">
            <style>
                body {{ padding: 20px; background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }}
                .container-fluid {{ background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }}
                h2 {{ color: #0d6efd; margin-bottom: 20px; border-bottom: 2px solid #0d6efd; padding-bottom: 10px; }}
            </style>
        </head>
        <body>
            <div class="container-fluid">
                <h2> MonitorDB - Aktuální stav úloh ({time.strftime('%H:%M:%S')})</h2>
                {df.to_html(classes='table table-hover table-striped', index=False, table_id='monitorTable')}
            </div>
            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
            <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
            <script>
                $(document).ready(function() {{
                    $('#monitorTable').DataTable({{
                        "language": {{ "url": "//cdn.datatables.net/plug-ins/1.13.4/i18n/cs.json" }},
                        "pageLength": 25,
                        "order": [[ 9, "desc" ]]
                    }});
                }});
            </script>
        </body>
        </html>
        """

        # 4. ZÁPIS SOUBORU - Musí být uvnitř while True smyčky!
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(html_template)
        
        print(f"Data aktualizována a uložena do: {output_path} ({time.strftime('%H:%M:%S')})")
        
        # Otevře prohlížeč jen při prvním průběhu (volitelné)
        # if 'opened' not in locals():
        #    webbrowser.open('file://' + output_path)
        #    opened = True

        time.sleep(30) 

except Exception as e:
    print(f"Chyba: {e}")