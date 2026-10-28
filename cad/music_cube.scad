// =====================================================================
//  Музыкальный куб — джукбокс из Minecraft (OpenSCAD)
//
//  Детали и цвета:
//    body        ×1  тёмный каркас (крыша, стенки, шахта для пластинки)
//    bottom      ×1  тёмное дно на 4 винтах — через него доступ к электронике
//    panel_side  ×4  оранжево-коричневые панели в шахматную клетку
//    panel_top   ×2  две половинки верхней панели (между ними тёмная полоса со щелью)
//    slot_unit   ×1  шахта со щелью — из СВЕТЛОГО полупрозрачного пластика, светится от светодиодов
//    disc        ×N  пиксельная пластинка с NFC-меткой внутри
//
//  Панели печатаются ЛИЦОМ ВНИЗ (фактура стола) и клеятся на каркас:
//  боковые — в ниши, верхние — рамкой-выступом в канавку на крыше.
//  Экспорт: выберите part -> F6 -> File -> Export -> STL.
// =====================================================================

part = "all"; // [all, body, bottom, panel_side, panel_top, slot_unit, disc]

/* [Куб] */
S        = 110;  // размер куба, мм
frame_b  = 8;    // ширина тёмной рамки по краям граней
wall     = 2.4;  // стенка за панелью
rim_h    = 1.6;  // глубина ниши под боковую панель
top_t    = 3;    // толщина крыши
bottom_t = 3;    // толщина дна

/* [Панели] */
panel_out    = 2.8;  // на сколько ВСЕ панели выступают над тёмным каркасом (одинаково со всех сторон)
// толщина боковой панели = panel_out + rim_h (часть сидит в нише), верхней = panel_out
panel_clear  = 0.5;  // зазор панели в нише
grid_n       = 9;    // клеток по стороне (нечётное -> узор симметричный)
web          = 1.6;  // перемычка между отверстиями
panel_margin = 5;    // поле от края панели до узора
band_w       = 16;   // ширина тёмной полосы со щелью на крыше
tongue_w     = 1.6;  // верхние панели: рамка-выступ на тыльной стороне...
tongue_h     = 1.5;
tongue_inset = 3;    // ...отступ рамки от края панели
groove_clear = 0.4;  // зазор выступа в канавке крыши (по ширине, суммарно)

/* [Пластинка] */
disc_px   = 14;   // диаметр в «пикселях»
px        = 6;    // размер пикселя, мм  -> диск 84 мм
disc_t    = 3.0;  // толщина диска
label_h   = 0.8;  // выпуклая цветная «этикетка» (смена цвета пластика)
stick_out = 13;   // сколько диска торчит над верхними панелями
tag_d     = 26;   // карман под NTAG215 Ø25
tag_floor = 1.0;
tag_depth = 0.6;

/* [Шахта и NFC] */
slot_clear     = 1.0;  // зазор щели по толщине
slot_len_clear = 1.6;  // зазор щели по длине
sleeve_wall    = 1.6;
flange_w       = 2.5;  // ширина светящейся рамки вокруг щели
flange_h       = 1.5;  // на сколько рамка выступает над крышей
ledge_w        = 2;    // уступ под крышей, держит шахту изнутри
unit_clear     = 0.3;  // зазор шахты в отверстии крыши (суммарно)
// Синий модуль PN532 78.5×49 мм с 4 отверстиями Ø3.5 — ИЗМЕРЬТЕ свой:
nfc_len        = 78.5; // длина платы (разъём на одном коротком краю)
nfc_wid        = 49;   // ширина платы
nfc_ant        = 25;   // от края БЕЗ разъёма до центра антенны (логотипа NFC)
nfc_hole_in    = 4;    // от края платы до центра крепёжного отверстия
standoff_h     = 4;    // стойки: плата отстоит от шахты (место под пайку)
standoff_d     = 7;
standoff_hole  = 2.6;  // под саморез M3×6

/* [Динамики — спереди и сзади] */
spk_d      = 40;   // диаметр динамика
spk_ring_h = 4;

/* [Кнопки и кабель — сзади, сквозь отверстия узора] */
btn_hole   = 4.2;  // под толкатель тактовой кнопки 6×6 (высота 8–9 мм)
btn_body   = 6.4;
cable_hole = 6;    // кабель питания выходит через угловое отверстие узора

/* [Крепёж дна] */
post_d      = 9;
screw_hole  = 2.6;  // саморез M3 (под вплавляемую гайку — 4.2)
screw_clear = 3.4;
csk_d       = 6.4;

$fn = 64;

// ---------------------------------------------------------------------
wo      = wall + rim_h;
side_pt = panel_out + rim_h;                   // толщина боковой панели
top_pt  = panel_out;                           // толщина верхней панели                    // полная толщина стенки
pocket  = S - 2*frame_b;
panel   = pocket - panel_clear;
cell    = (panel - 2*panel_margin) / grid_n;
hole_sz = cell - web;
disc_d  = disc_px * px;
slot_w  = disc_t + label_h + slot_clear;
slot_l  = disc_d + slot_len_clear;
sl_ox   = slot_l + 2*sleeve_wall;              // внешние размеры шахты
sl_oy   = slot_w + 2*sleeve_wall;
floor_z = S + top_pt - (disc_d - stick_out);  // дно шахты
disc_cz = floor_z + disc_d/2;                  // центр диска = центр NFC-модуля
pc      = S/2 - wo - post_d/2 + 0.6;           // угловые стойки (чуть утоплены в стенки)
half_d  = (panel - band_w) / 2;                // глубина половинки верхней панели
top_y   = band_w/2 + half_d/2;                 // центр половинки верхней панели по Y

function grid_c(i)    = (i - (grid_n-1)/2) * cell;
function is_hole(i,j) = (i + j) % 2 == 0;
// Сколько пикселей в ряду j пиксельного круга (ряды симметричны)
function row_px(j) = 2 * floor(sqrt(max(0, pow(disc_px/2, 2) - pow(j-(disc_px-1)/2, 2))) + 0.5);

// Ставит детей на 4 боковые грани. Локальные координаты — передняя грань:
// плоскость XZ, снаружи y = -S/2, X вправо (если смотреть на грань).
module each_face(faces=[0,1,2,3]) {
    for (f = faces) rotate([0,0,f*90]) children();
}

// ---------------------------------------------------------------------
module body() {
    difference() {
        union() {
            // оболочка с крышей, открытая снизу
            difference() {
                translate([-S/2, -S/2, bottom_t]) cube([S, S, S - bottom_t]);
                translate([-S/2+wo, -S/2+wo, bottom_t-1]) cube([S-2*wo, S-2*wo, S-bottom_t-top_t+1]);
            }
            // угловые стойки под винты дна
            for (x=[-1,1], y=[-1,1])
                translate([x*pc, y*pc, bottom_t]) cylinder(d=post_d, h=S-bottom_t-top_t+0.01);
            // посадочные кольца динамиков (перед и зад)
            each_face([0,2]) translate([0, -S/2+wo-0.2, S/2]) rotate([-90,0,0])
                difference() {
                    cylinder(d=spk_d+5, h=spk_ring_h+0.2);
                    translate([0,0,-0.1]) cylinder(d=spk_d+0.6, h=spk_ring_h+0.2);
                }
            // держатели кнопок (изнутри задней стенки)
            each_face([2]) for (i=[2,4,6])
                translate([grid_c(i), -S/2+wo-0.2, S/2+grid_c(0)]) rotate([-90,0,0])
                    difference() {
                        translate([-(btn_body+3)/2, -(btn_body+3)/2, 0]) cube([btn_body+3, btn_body+3, 3.2]);
                        translate([-btn_body/2, -btn_body/2, -0.1]) cube([btn_body, btn_body, 3.2]);
                    }
        }
        // ниши под боковые панели
        each_face() translate([-pocket/2, -S/2-1, frame_b]) cube([pocket, rim_h+1, pocket]);
        // окна под динамики (закрыты панелью)
        each_face([0,2]) translate([0, -S/2, S/2]) rotate([90,0,0])
            cylinder(d=spk_d-4, h=4*wo, center=true);
        // кнопки и кабель — напротив отверстий узора в нижнем ряду задней панели
        each_face([2]) {
            for (i=[2,4,6]) translate([grid_c(i), -S/2, S/2+grid_c(0)]) rotate([90,0,0])
                cylinder(d=btn_hole, h=4*wo, center=true);
            translate([grid_c(grid_n-1), -S/2, S/2+grid_c(0)]) rotate([90,0,0])
                cylinder(d=cable_hole, h=4*wo, center=true);
        }
        // отверстие в крыше под шахту (шахта — отдельная светящаяся деталь)
        translate([-(plug_x+unit_clear)/2, -(plug_y+unit_clear)/2, S-top_t-1])
            cube([plug_x+unit_clear, plug_y+unit_clear, top_t+2]);
        // канавки-пазы под рамки верхних панелей (узкие — печатаются без поддержек)
        for (sy=[-1,1]) translate([0, sy*top_y, S-tongue_h-0.3]) top_frame(groove_clear, tongue_h+1);
        // отверстия в стойках
        for (x=[-1,1], y=[-1,1])
            translate([x*pc, y*pc, bottom_t-0.1]) cylinder(d=screw_hole, h=16, $fn=24);
    }
}

// ---------------------------------------------------------------------
// Шахта со щелью. Печатать из натурального PETG или белого PLA, рамкой на стол.
// Ставится ИЗНУТРИ (снизу, пока дно снято): рамка выходит в отверстие крыши
// и светится, уступ упирается в крышу изнутри — клеится по уступу.
// Светодиоды клеятся на переднюю стенку шахты (y < 0), PN532 — на стойки сзади.
plug_x  = sl_ox + 2*flange_w;                  // светящаяся рамка (проходит сквозь крышу)
plug_y  = sl_oy + 2*flange_w;

// Положение платы PN532: антенна напротив центра пластинки, но плата не должна
// упираться в стенку корпуса и в крышу (смещение антенны выводится в консоль)
nfc_x0  = min(-nfc_ant, S/2 - wo - 1.5 - nfc_len);   // край платы без разъёма
nfc_zc  = min(disc_cz, S - top_t - 1 - nfc_wid/2);    // центр платы по высоте
nfc_y0  = slot_w/2 + sleeve_wall;                     // наружная сторона задней стенки шахты

module slot_unit() {
    difference() {
        union() {
            // труба шахты
            translate([-sl_ox/2, -sl_oy/2, floor_z-sleeve_wall])
                cube([sl_ox, sl_oy, S-top_t-floor_z+sleeve_wall+0.01]);
            // рамка сквозь крышу
            translate([-plug_x/2, -plug_y/2, S-top_t]) cube([plug_x, plug_y, top_t+flange_h]);
            // уступ под крышей (спереди и по торцам; сзади его нет — там плата PN532)
            translate([-plug_x/2-ledge_w, -plug_y/2-ledge_w, S-top_t-2])
                cube([plug_x+2*ledge_w, plug_y/2+ledge_w, 2.01]);
            // площадка под плату PN532 (шире трубы, чтобы достать до правых отверстий)
            translate([nfc_x0-1, nfc_y0-sleeve_wall, nfc_zc-nfc_wid/2])
                cube([nfc_len+2, sleeve_wall, nfc_wid]);
            // стойки
            for (hx=[nfc_x0+nfc_hole_in, nfc_x0+nfc_len-nfc_hole_in], hz=[-1,1])
                translate([hx, nfc_y0-0.2, nfc_zc + hz*(nfc_wid/2-nfc_hole_in)]) rotate([-90,0,0])
                    cylinder(d=standoff_d, h=standoff_h+0.2);
        }
        // щель
        translate([-slot_l/2, -slot_w/2, floor_z]) cube([slot_l, slot_w, S]);
        // глухие отверстия в стойках (в щель не выходят)
        for (hx=[nfc_x0+nfc_hole_in, nfc_x0+nfc_len-nfc_hole_in], hz=[-1,1])
            translate([hx, nfc_y0+0.6, nfc_zc + hz*(nfc_wid/2-nfc_hole_in)]) rotate([-90,0,0])
                cylinder(d=standoff_hole, h=standoff_h+1, $fn=20);
    }
}

// ---------------------------------------------------------------------
module bottom() {
    lip = S - 2*wo - 0.6;
    difference() {
        union() {
            translate([-S/2, -S/2, 0]) cube([S, S, bottom_t]);
            // бортик для центровки внутри стенок
            difference() {
                translate([-lip/2, -lip/2, bottom_t]) cube([lip, lip, 2]);
                translate([-lip/2+1.6, -lip/2+1.6, bottom_t-0.1]) cube([lip-3.2, lip-3.2, 2.2]);
                for (x=[-1,1], y=[-1,1]) translate([x*pc, y*pc, 0]) cylinder(d=post_d+1, h=10);
            }
        }
        // винты с зенковкой снизу
        for (x=[-1,1], y=[-1,1]) translate([x*pc, y*pc, 0]) {
            translate([0,0,-0.1]) cylinder(d=screw_clear, h=bottom_t+0.2, $fn=24);
            translate([0,0,-0.01]) cylinder(d1=csk_d, d2=screw_clear, h=(csk_d-screw_clear)/2, $fn=24);
        }
        // углубления под резиновые ножки
        for (x=[-1,1], y=[-1,1]) translate([x*(S/2-24), y*(S/2-24), -0.1]) cylinder(d=10.5, h=1.1);
    }
}

// ---------------------------------------------------------------------
// Ориентация печати: лицо на столе (z = 0).
module panel_side() {
    difference() {
        translate([-panel/2, -panel/2, 0]) cube([panel, panel, side_pt]);
        for (i=[0:grid_n-1], j=[0:grid_n-1]) if (is_hole(i,j))
            translate([grid_c(i)-hole_sz/2, grid_c(j)-hole_sz/2, -1])
                cube([hole_sz, hole_sz, side_pt+2]);
    }
}

module panel_top() {
    translate([-panel/2, -half_d/2, 0]) cube([panel, half_d, top_pt]);
    // рамка-выступ на тыльной стороне — входит в канавку на крыше
    translate([0, 0, top_pt-0.01]) top_frame(0, tongue_h+0.01);
}

// Прямоугольная рамка: выступ панели (clear = 0) или канавка в крыше (clear > 0)
module top_frame(clear, h) {
    ox = panel  - 2*tongue_inset + clear;
    oy = half_d - 2*tongue_inset + clear;
    ix = panel  - 2*tongue_inset - 2*tongue_w - clear;
    iy = half_d - 2*tongue_inset - 2*tongue_w - clear;
    difference() {
        translate([-ox/2, -oy/2, 0]) cube([ox, oy, h]);
        translate([-ix/2, -iy/2, -1]) cube([ix, iy, h+2]);
    }
}

// ---------------------------------------------------------------------
// Ориентация печати: плоско. Пауза — вклеить метку, смена цвета — этикетка.
// Пиксельный круг: по одному прямоугольнику на ряд — считается быстро
module disc_pixels(h) {
    for (j=[0:disc_px-1]) if (row_px(j) > 0)
        translate([-row_px(j)*px/2, (j - disc_px/2)*px - 0.005, 0])
            cube([row_px(j)*px, px+0.01, h]);
}

// Этикетка-«бублик»: квадрат 4×4 пикселя без центра 2×2
module disc_label(h) {
    difference() {
        translate([-2*px, -2*px, 0]) cube([4*px, 4*px, h]);
        translate([-px, -px, -1]) cube([2*px, 2*px, h+2]);
    }
}

module disc() {
    difference() {
        disc_pixels(disc_t);
        translate([0,0,tag_floor]) cylinder(d=tag_d, h=tag_depth);
    }
    translate([0,0,disc_t-0.01]) disc_label(label_h+0.01);
}

echo(str("Диск ", disc_d, " мм. ПАУЗА (вклеить метку) на Z = ", tag_floor + tag_depth,
         " мм; СМЕНА ЦВЕТА (этикетка) на Z = ", disc_t, " мм"));
echo(str("Боковых панелей: 4 шт ", panel, "×", panel, "×", side_pt, " мм; верхних: 2 шт толщиной ", top_pt, " мм; выступ везде ", panel_out, " мм"));
echo(str("PN532: антенна смещена от центра пластинки на ", nfc_x0 + nfc_ant, " мм по X и ", nfc_zc - disc_cz, " мм по высоте"));

// ---------------------------------------------------------------------
if (part == "body") rotate([180,0,0]) translate([0,0,-S]) body();   // крышей на стол
else if (part == "bottom") bottom();
else if (part == "panel_side") panel_side();
else if (part == "panel_top") panel_top();
else if (part == "slot_unit") translate([0,0,S+flange_h]) rotate([180,0,0]) slot_unit();  // рамкой на стол
else if (part == "disc") disc();
else {
    dark = [0.18,0.16,0.16]; orange = [0.72,0.36,0.22];
    color(dark) body();
    color([0.95,0.93,0.85]) translate([0,0,-0.05]) slot_unit();
    color([0.1,0.3,0.7]) translate([nfc_x0, nfc_y0+standoff_h+0.05, nfc_zc-nfc_wid/2]) cube([nfc_len, 1.6, nfc_wid]);  // плата PN532 (для наглядности)
    // в сборке детали разведены на 0.05 мм, чтобы просмотрщики не спотыкались о касания
    color(dark) translate([0,0,-0.05]) bottom();
    color(orange) each_face()
        translate([0, -S/2+rim_h-0.05, S/2]) rotate([90,0,0]) panel_side();
    color(orange) for (sy=[-1,1])
        translate([0, sy*top_y, S+top_pt+0.05]) mirror([0,0,1]) panel_top();
    // пластинка в щели
    translate([0, (disc_t+label_h)/2, disc_cz+0.05]) rotate([90,0,0]) {
        color([0.1,0.1,0.1]) difference() {
            disc_pixels(disc_t);
            translate([0,0,tag_floor]) cylinder(d=tag_d, h=tag_depth);
        }
        color([0.3,0.8,0.4]) translate([0,0,disc_t-0.01]) disc_label(label_h+0.01);
    }
}
