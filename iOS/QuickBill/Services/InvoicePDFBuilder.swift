//
//  InvoicePDFBuilder.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 12/5/25.
//

import UIKit
import PDFKit

struct InvoicePDFBuilder {
    
    /// Devuelve la URL del PDF generado en el directorio *Documents*
    static func createPDF(for invoice: Invoice,
                          clientName: String,
                          products: [ProductStack]) throws -> URL {
        
        // 1) Canvas A4
        let pdfMetaData = [
            kCGPDFContextCreator: "QuickBill",
            kCGPDFContextAuthor:  "QuickBill"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 @72 dpi
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            drawInvoice(invoice,
                        clientName: clientName,
                        products: products,
                        in: pageRect)
        }
        
        // 2) Guardar en Documents/Invoice-<id>.pdf
        let docs = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("Invoice-\(invoice.id).pdf")
        try data.write(to: url, options: .atomic)
        return url
    }
    
    // MARK: - Drawing helpers
    private static func drawInvoice(_ inv: Invoice,
                                    clientName: String,
                                    products: [ProductStack],
                                    in rect: CGRect) {
        // Fuentes
        let titleFont   = UIFont.boldSystemFont(ofSize: 24)
        let labelFont   = UIFont.systemFont(ofSize: 12)
        let textFont    = UIFont.systemFont(ofSize: 12)
        let boldFont    = UIFont.boldSystemFont(ofSize: 12)
        
        var y: CGFloat = 36
        
        // Title
        "INVOICE".draw(at: CGPoint(x: rect.midX-40, y: y),
                       withAttributes: [.font: titleFont])
        y += 40
        
        // Company & Client blocks
        func drawBlock(label: String, lines: [String]) {
            label.uppercased().draw(at: CGPoint(x: 36, y: y),
                                    withAttributes: [.font: boldFont])
            y += 14
            for line in lines {
                line.draw(at: CGPoint(x: 42, y: y),
                          withAttributes: [.font: textFont])
                y += 14
            }
            y += 10
        }
        
        drawBlock(label: "Your company",
                  lines: [inv.companyName])
        drawBlock(label: "Bill to",
                  lines: [clientName])
        
        // Invoice meta
        "Invoice #\(inv.id)".draw(at: CGPoint(x: 400, y: 80),
                                  withAttributes: [.font: boldFont])
        "Issued: \(date(inv.issuedAt))".draw(at: CGPoint(x: 400, y: 94),
                                             withAttributes: [.font: labelFont])
        "Due:    \(date(inv.dueDate))".draw(at: CGPoint(x: 400, y: 108),
                                            withAttributes: [.font: labelFont])
        
        y = max(y, 140)
        // Table header
        let colX: [CGFloat] = [36, 250, 330, 420, 500]
        ["Description","Supply","Qty","Unit","Amount"].enumerated().forEach { idx, txt in
            txt.draw(at: CGPoint(x: colX[idx], y: y),
                     withAttributes: [.font: boldFont])
        }
        y += 16
        UIColor.black.setStroke()
        UIBezierPath(rect: CGRect(x: 36, y: y, width: 524, height: 1)).fill()
        y += 6
        
        // Table rows
        products.forEach { p in
            let total = String(format: "%.2f", p.amount)
            let unit  = String(format: "%.2f", p.amount / Double(p.quantity))
            let cols = [
                p.productId,
                date(p.supplyDate),
                "\(p.quantity)",
                unit,
                total
            ]
            for (i, txt) in cols.enumerated() {
                txt.draw(at: CGPoint(x: colX[i], y: y),
                         withAttributes: [.font: textFont])
            }
            y += 14
        }
        
        // Subtotals
        y += 10
        func amountRow(_ label: String, _ value: Double, bold: Bool = false) {
            let attr: [NSAttributedString.Key: Any] = [.font: bold ? boldFont : textFont]
            label.draw(at: CGPoint(x: 400, y: y), withAttributes: attr)
            let val = String(format: "%.2f %@", value, inv.currency)
            val.draw(at: CGPoint(x: 500 - (val as NSString).size(withAttributes: attr).width, y: y),
                     withAttributes: attr)
            y += 14
        }
        amountRow("Subtotal",  inv.subtotal)
        amountRow("Tax",       inv.taxTotal)
        amountRow("Discounts", inv.discounts)
        UIBezierPath(rect: CGRect(x: 400, y: y, width: 160, height: 1)).fill()
        y += 4
        amountRow("TOTAL",     inv.totalAmount, bold: true)
    }
    
    private static func date(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        return df.string(from: d)
    }
}
