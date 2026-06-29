import sys
import subprocess

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

try:
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import letter
    from reportlab.lib import colors
except ImportError:
    install('reportlab')
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import letter
    from reportlab.lib import colors

def create_pdf(path):
    c = canvas.Canvas(path, pagesize=letter)
    width, height = letter
    
    # Title
    c.setFont("Helvetica-Bold", 24)
    c.drawString(50, height - 50, "Demo Customer Form")
    
    c.setFont("Helvetica", 12)
    c.drawString(50, height - 80, "Please use this form as a reference for data entry.")
    
    # Draw a line
    c.line(50, height - 90, width - 50, height - 90)
    
    # Data Dictionary
    data = {
        "Serial No": "1",
        "Title": "Miss.",
        "First Name": "Ashlynn",
        "Last Name": "Lipscomb",
        "Initial": "Parish",
        "Email": "ashlynnlipscomb@gmail.com",
        "Father Name": "Zole",
        "DOB": "2006-08-27",
        "Gender": "Female",
        "Profession": "Shop Manager",
        "Mailing Street": "777 Elmwood Dr",
        "Mailing City": "Atlanta",
        "Mailing Postal Code": "30302",
        "Mailing Country": "USA",
        "Service Provider": "Shaw Communications",
        "File No": "76180379",
        "Reference No": "@j_>B...[S|<?6]",
        "Sim No": "49019504522720900000",
        "Type Of Network": "Shaw Communications",
        "Cell Model No": "799228773",
        "IMSI 1": "828120726858670",
        "IMSI 2": "2410317799J...",
        "Type Of Plan": "Healthcare Plans",
        "Credit Card Type": "Dunkin1",
        "Contract Value": "USD150",
        "Date Of Issue": "2004-12-08",
        "Date Of Renewal": "2007-12-08",
        "Installment": "4.596",
        "Amount In Words": "Four Point Five Ninety Six",
        "Remarks": "Not Applicable"
    }
    
    y_position = height - 130
    x_col1 = 50
    x_col2 = 300
    
    col = 1
    for key, value in data.items():
        if col == 1:
            c.setFont("Helvetica-Bold", 10)
            c.drawString(x_col1, y_position, f"{key}:")
            c.setFont("Helvetica", 10)
            c.drawString(x_col1 + 100, y_position, value)
            col = 2
        else:
            c.setFont("Helvetica-Bold", 10)
            c.drawString(x_col2, y_position, f"{key}:")
            c.setFont("Helvetica", 10)
            c.drawString(x_col2 + 120, y_position, value)
            col = 1
            y_position -= 30
            
            if y_position < 50:
                c.showPage()
                y_position = height - 50
                
    c.save()
    print(f"Successfully generated {path}")

if __name__ == '__main__':
    create_pdf('demo_form.pdf')
