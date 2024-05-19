# docugenr8: A Library for Generating Documents

docugenr8 is a Python library designed to help you generate various types of documents effortlessly. Currently, it supports creating PDF files, and work is underway to extend its capabilities to generate BMP, PNG, JPEG, TIFF, ODT, DOCX, and RTF documents.

## Key Features

- **Simple Global Settings**: Easily change global settings such as colors, fonts, and font sizes. No need to redefine these settings each time; the most recent settings are automatically applied to all new elements.
- **Effortless Text Box Creation**: Create text boxes without worrying about text line placement. Text box horizontal alignment options: right, centered, left, and justified. Text box vertical alignment options: top, bottom, center, justified-between-lines, and justified-between-paragraphs.
- **Advanced Paragraph Formatting**: Customize paragraph formatting with options like line height, tab size, word splitting, and indents.
- **Page Numbers**: Insert page numbers (current page and total pages) anywhere in the text box. Choose from different numbering styles such as Arabic, Roman, etc.
- **Linked Text Boxes**: Link text boxes together for continuous text flow, similar to writing in a Word document.
- **Table Creation and Customization**: Easily create and fill tables. Customize cell and border colors individually or by rows and columns.
- **PDF Optimization**: Significantly reduce document size (up to 40 times) with font subsetting.
- **Minimal Dependencies**: Currently, it only depends on fonttools. Work is underway to make it a zero-dependency library.

## Structure

The docugenr8 library consists of three independent modules:

### docugenr8-core

- Generates the structure of the document.
- Adds fonts and images for use in documents.
- Defines document structure, including pages, shapes, images, tables, and text boxes.
- Utilizes a coordinate system with x, y positions, width, and height.
- Allows customization of font size, color, name, background, and border color.

### docugenr8-shared

- Defines data transfer objects (DTOs) to facilitate data transfer between modules.
- Contains shared functions used across all modules.

### docugenr8-pdf

- Creates PDF files by reading DTOs created by the core module.
- Implements font subsetting to significantly reduce file size.

## Installation

Install docugenr8 using pip:

```sh
pip install docugenr8
```

## Example

Create a PDF document with a text box and a table.

Create a file main.py with:

```python
from docugenr8.core import Document, TextBox, Table
from docugenr8.pdf import PDFGenerator

# Create a new document
doc = Document()

# Add a text box
text_box = TextBox(x=50, y=700, width=500, height=100, text="Hello, World!", font_size=12)
doc.add_text_box(text_box)

# Add a table
table = Table(x=50, y=500, width=500, height=200, rows=5, columns=3)
doc.add_table(table)

# Generate PDF
pdf_gen = PDFGenerator()
pdf_gen.generate(doc, "output.pdf")
```

## Usage
Run the script with:
```sh
python main.py
```

This will generate a PDF file named output.pdf in the current directory.

## Advanced Usage

### Global Settings

Set global settings for the document:

```python
from docugenr8.core import GlobalSettings

GlobalSettings.set_color("blue")
GlobalSettings.set_font("Arial")
GlobalSettings.set_font_size(14)
```

### Linked Text Boxes
Link text boxes for continuous text flow:

```python
text_box1 = TextBox(x=50, y=700, width=500, height=100, text="Part 1", font_size=12)
text_box2 = TextBox(x=50, y=600, width=500, height=100, text="Part 2", font_size=12)
text_box1.link(text_box2)
doc.add_text_box(text_box1)
doc.add_text_box(text_box2)
```

### Table Customization
Customize table cells and borders:

```python
Copy code
table.set_cell_color(0, 0, "lightgrey")
table.set_border_color("black")
```

## Interactive Documentation
Check out the interactive API documentation at API Docs.

## License
This project is licensed under the terms of the MIT license.
