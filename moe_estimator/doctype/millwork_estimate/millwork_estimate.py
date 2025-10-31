import frappe
from frappe.model.document import Document

class MillworkEstimate(Document):
    def validate(self):
        total = 0
        for row in (self.items or []):
            row.total = (row.qty or 0) * ((row.material_cost or 0) + (row.labor_cost or 0))
            total += row.total or 0
        self.total = total
