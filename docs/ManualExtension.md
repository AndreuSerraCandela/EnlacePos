# Manual de Extensiones de Tabla

## Descripción General
Este documento describe las extensiones de tabla implementadas para personalizar la configuración de ventas, compras e inventario en Business Central.

## 1. Extensión de Configuración de Ventas (SalesSetup)
**ID de Extensión:** 75200
**Tabla Base:** "Sales & Receivables Setup"

### Campos Agregados

| Campo | ID | Tipo | Descripción |
|-------|----|------|-------------|
| CustomerTemplate | 90100 | Code[20] | Plantilla predeterminada para nuevos clientes |
| Nums. Turno | 90102 | Code[20] | Serie de números para turnos |
| Nums. Caja | 90103 | Code[20] | Serie de números para cajas |
| Nums. Colegio | 90104 | Code[20] | Serie de números para colegios |
| Nums. TPV | 90105 | Code[20] | Serie de números para terminales punto de venta |

## 2. Extensión de Configuración de Compras (PurchSetup)
**ID de Extensión:** 75201
**Tabla Base:** 312 (Purchases & Payables Setup)

### Campos Agregados

| Campo | ID | Tipo | Descripción |
|-------|----|------|-------------|
| VendorTemplate | 90100 | Code[20] | Plantilla predeterminada para nuevos proveedores |

## 3. Extensión de Configuración de Inventario (ItemSetup)
**ID de Extensión:** 75203
**Tabla Base:** 313 (Inventory Setup)

### Campos Agregados

| Campo | ID | Tipo | Descripción |
|-------|----|------|-------------|
| ItemTemplate | 90100 | Code[20] | Plantilla predeterminada para nuevos productos |

## Uso de las Extensiones

### Configuración de Ventas
1. Acceda a la configuración de ventas y cobros
2. Configure las series de números para:
   - Turnos
   - Cajas
   - Colegios
   - Terminales punto de venta
3. Establezca la plantilla predeterminada para nuevos clientes

### Configuración de Compras
1. Acceda a la configuración de compras y pagos
2. Configure la plantilla predeterminada para nuevos proveedores

### Configuración de Inventario
1. Acceda a la configuración de inventario
2. Configure la plantilla predeterminada para nuevos productos

## Notas Importantes
- Todas las plantillas (Customer, Vendor, Item) están vinculadas a sus respectivas tablas de plantillas
- Las series de números deben estar previamente configuradas en el sistema
- Los campos de plantilla son obligatorios para mantener la consistencia en la creación de nuevos registros 