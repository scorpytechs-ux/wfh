import sys
import subprocess

try:
    from reportlab.pdfgen import canvas
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "reportlab"])
    from reportlab.pdfgen import canvas

def create_simple_form():
    c = canvas.Canvas('demo_form_2.pdf')

    c.setFont("Helvetica", 16)
    c.drawString(50, 800, "Employee Onboarding Form")

    c.setFont("Helvetica", 12)
    form = c.acroForm

    c.drawString(50, 750, "Full Name:")
    form.textfield(name='full_name', tooltip='Full Name',
                   x=150, y=745, borderStyle='inset',
                   width=300)

    c.drawString(50, 700, "Department:")
    form.textfield(name='department', tooltip='Department',
                   x=150, y=695, borderStyle='inset',
                   width=300)
                   
    c.drawString(50, 650, "Role:")
    form.textfield(name='role', tooltip='Role',
                   x=150, y=645, borderStyle='inset',
                   width=300)

    c.drawString(50, 600, "Experience (Years):")
    form.textfield(name='experience', tooltip='Experience',
                   x=180, y=595, borderStyle='inset',
                   width=270)

    c.save()

if __name__ == '__main__':
    create_simple_form()
