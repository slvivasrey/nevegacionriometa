* =============================================================================
* Gráficos del sitio "Río Meta 1940–1970"
* Historia Económica de Colombia, 2026-2 · Sarah Lucía Vivas
* Lee los CSV de datos/ y guarda cada gráfico como PNG en img/graficos/.
* Corra el do-file COMPLETO de una vez (los locals se pierden si corre por partes).
* =============================================================================

clear all
set more off
set dp comma
cd "~/Desktop/2026-2/Historia Económica de Colombia/Trabajo Final/sitio"
capture mkdir "img/graficos"

* --- Paleta del sitio (RGB) ---------------------------------------------------
local tinta "27 38 35"
local gris  "86 99 93"
local agua  "43 105 112"
local limo  "162 107 28"
local papel "237 240 233"
local linea "198 205 193"
local fondo graphregion(color("237 240 233") lcolor("237 240 233")) plotregion(color("237 240 233") lcolor("237 240 233"))
local rejilla ylabel(, glcolor("198 205 193") glwidth(vthin))

* =============================================================================
* 1. Carreteras nacionales, 1932–1948
* =============================================================================
import delimited "datos/carreteras_nacionales_km.csv", clear encoding("utf-8") varnames(1)

twoway (connected km anio, lcolor("`tinta'") mcolor("`tinta'") lwidth(medthick) msize(medium)), ///
    xline(1936, lpattern(dash) lcolor("`limo'")) ///
    text(12000 1936.3 "Carretera Bogotá–Villavicencio", place(e) color("`limo'") size(small)) ///
    xlabel(1932(4)1948, nogrid) ///
    ylabel(0(2000)12000, format(%9.0fc) angle(0) glcolor("`linea'") glwidth(vthin)) ///
    ytitle("Kilómetros") xtitle("") legend(off) `fondo'
graph export "img/graficos/carreteras.png", replace width(1600)

* =============================================================================
* 2. Carga por modo de transporte, 1947
* =============================================================================
import delimited "datos/carga_por_modo_1947.csv", clear encoding("utf-8") varnames(1)

gsort -porcentaje
gen pos = _n
forvalues i = 1/`=_N' {
    label define pos_lbl `i' "`=modo[`i']'", add
}
label values pos pos_lbl
gen fluvial  = strpos(modo, "fluvial") > 0
gen cero     = 0
gen etiqueta = subinstr(string(porcentaje, "%4.1f"), ".", ",", .) + "%"

twoway (rbar cero porcentaje pos if !fluvial, horizontal barwidth(0.65) color("`gris'")) ///
       (rbar cero porcentaje pos if fluvial,  horizontal barwidth(0.65) color("`agua'")) ///
       (scatter pos porcentaje, msymbol(none) mlabel(etiqueta) mlabposition(3) mlabcolor("`tinta'")), ///
    yscale(reverse) ylabel(1(1)4, valuelabel angle(0) noticks nogrid) ///
    xlabel(0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%", glcolor("`linea'") glwidth(vthin)) ///
    xscale(range(0 42)) ytitle("") xtitle("Porcentaje de las toneladas-kilómetro") ///
    legend(off) `fondo'
graph export "img/graficos/carga_modos_1947.png", replace width(1600)

* =============================================================================
* 3. Carga del río Magdalena, 1915–1956
* =============================================================================
import delimited "datos/carga_rio_magdalena.csv", clear encoding("utf-8") varnames(1)

gen millones = toneladas / 1e6
twoway (connected millones anio, lcolor("`agua'") mcolor("`agua'") lpattern(dash) ///
        lwidth(medthick) mlabel(anio) mlabposition(12) mlabcolor("`gris'") mlabsize(small)), ///
    xlabel(1915(5)1955, nogrid) ///
    ylabel(0(0.5)2.5, format(%3.1f) angle(0) glcolor("`linea'") glwidth(vthin)) ///
    ytitle("Millones de toneladas") xtitle("") legend(off) `fondo'
graph export "img/graficos/magdalena.png", replace width(1600)

* =============================================================================
* 4. Población según los censos (Meta, Villavicencio, Puerto López)
* =============================================================================
import delimited "datos/poblacion_meta_censos.csv", clear encoding("utf-8") varnames(1)

gen u = cond(strpos(unidad, "Meta") > 0, 1, cond(unidad == "Villavicencio", 2, 3))

* Tasas de crecimiento anual del Meta (geométricas, entre fechas censales)
preserve
keep if u == 1
sort anio_censo
gen fecha = mdy(7, 5, 1938) in 1
replace fecha = mdy(5, 9, 1951) in 2
replace fecha = mdy(7, 15, 1964) in 3
gen anios = (fecha - fecha[_n-1]) / 365.25
gen tasa_anual = 100 * ((poblacion_total / poblacion_total[_n-1])^(1 / anios) - 1)
list anio_censo poblacion_total tasa_anual, noobs
restore

keep u anio_censo poblacion_total
reshape wide poblacion_total, i(anio_censo) j(u)

graph bar (asis) poblacion_total1 poblacion_total2 poblacion_total3, ///
    over(anio_censo) ///
    bar(1, color("`tinta'")) bar(2, color("`gris'")) bar(3, color("`agua'")) ///
    blabel(bar, format(%9.0fc) size(vsmall) color("`tinta'")) ///
    legend(order(1 "Meta" 2 "Villavicencio" 3 "Puerto López") rows(1) position(6) region(lcolor(none) fcolor("`papel'"))) ///
    ylabel(, format(%9.0fc) angle(0) glcolor("`linea'") glwidth(vthin)) ///
    ytitle("Habitantes") `fondo'
graph export "img/graficos/poblacion_censos.png", replace width(1600)

* =============================================================================
* 5. Municipios del Meta en 1964: cabecera y resto
* =============================================================================
import delimited "datos/municipios_meta_1964.csv", clear encoding("utf-8") varnames(1)

gen pct_rural = 100 * resto / total
gsort -pct_rural
list municipio total pct_rural, noobs

graph hbar (asis) cabecera resto, ///
    over(municipio, sort(total) descending label(labsize(small))) stack ///
    bar(1, color("`agua'")) bar(2, color("`limo'")) ///
    legend(order(1 "Cabecera" 2 "Resto del municipio") rows(1) position(6) region(lcolor(none) fcolor("`papel'"))) ///
    ylabel(, format(%9.0fc) glcolor("`linea'") glwidth(vthin)) ///
    ytitle("Habitantes") `fondo' ysize(6.5) xsize(8)
graph export "img/graficos/municipios_1964.png", replace width(1600)

* =============================================================================
* 6. Pirámide de población de Puerto López, 1964
* =============================================================================
import delimited "datos/piramide_puerto_lopez_1964.csv", clear encoding("utf-8") varnames(1) stringcols(1)

gen g = _n
forvalues i = 1/`=_N' {
    label define edad_lbl `i' "`=grupo_edad[`i']'", add
}
label values g edad_lbl
gen hombres_neg = -hombres

* Índice de masculinidad (hombres por cada 100 mujeres)
quietly summarize hombres
local th = r(sum)
quietly summarize mujeres
local tm = r(sum)
display "Hombres por cada 100 mujeres: " %5.1f 100 * `th' / `tm'

twoway (bar hombres_neg g, horizontal barwidth(0.9) color("`agua'")) ///
       (bar mujeres g,     horizontal barwidth(0.9) color("`limo'")), ///
    ylabel(1(1)19, valuelabel angle(0) labsize(small) nogrid) ///
    xlabel(-1500 "1.500" -1000 "1.000" -500 "500" 0 "0" 500 "500" 1000 "1.000" 1500 "1.500", ///
        glcolor("`linea'") glwidth(vthin)) ///
    xline(0, lcolor("`tinta'") lwidth(thin)) ///
    legend(order(1 "Hombres" 2 "Mujeres") rows(1) position(6) region(lcolor(none) fcolor("`papel'"))) ///
    xtitle("Personas") ytitle("Grupo de edad") `fondo' ysize(7) xsize(7)
graph export "img/graficos/piramide_puerto_lopez.png", replace width(1400)

* =============================================================================
* 7. Parque automotor por departamento, 1960
* =============================================================================
import delimited "datos/parque_automotor_1960.csv", clear encoding("utf-8") varnames(1)

gsort -vehiculos
gen pos = _n
forvalues i = 1/`=_N' {
    label define dep_lbl `i' "`=departamento[`i']'", add
}
label values pos dep_lbl
gen es_meta  = departamento == "Meta"
gen cero     = 0
gen etiqueta = "1.429 vehículos, 0,8% del país" if es_meta

twoway (rbar cero vehiculos pos if !es_meta, horizontal barwidth(0.7) color("`gris'")) ///
       (rbar cero vehiculos pos if es_meta,  horizontal barwidth(0.7) color("`limo'")) ///
       (scatter pos vehiculos if es_meta, msymbol(none) mlabel(etiqueta) mlabposition(3) mlabcolor("`limo'")), ///
    yscale(reverse) ylabel(1(1)`=_N', valuelabel angle(0) labsize(small) noticks nogrid) ///
    xlabel(0(10000)60000, format(%9.0fc) glcolor("`linea'") glwidth(vthin)) ///
    ytitle("") xtitle("Vehículos") legend(off) `fondo' ysize(6) xsize(8)
graph export "img/graficos/parque_automotor_1960.png", replace width(1600)

display "Listo: 7 gráficos en img/graficos/"
