$fn = 100;

//mesures
largeur = 220;
profondeur = 220;
hauteur = 270;
epaisseur = 4;

//fenêtres
fenetreL = 120;
fenetreH = 100;
fenetreEp = 4;

//trou
entreeL = 50;
entreeH = 20;
union()
{
    translate([0,0,hauteur])
    {
        rotate([-70,0,0])
        cube([largeur, 4, 120]);

        translate([0,largeur,0])
        rotate([72,0,0])
        cube([largeur, 4, 120]);

        rotate([-90,0,0])
        cube([largeur, 4, largeur]);
    }
}
union()
{
    //corps
    difference()
    {
        //boîte
        cube([largeur,profondeur,hauteur]);
        
        //partie enlevée
        translate([epaisseur, epaisseur, epaisseur])
        cube([largeur-2*epaisseur, profondeur-2*epaisseur, hauteur]);
        
        //trou
        translate([largeur/2 - entreeL/2, -1, 200])
        cube([entreeL, epaisseur+2, entreeH]);
        
        translate([largeur/2 - entreeL/2, -1, 100])
        cube([entreeL, epaisseur+2, entreeH]);
        
        translate([largeur/2 - entreeL/2, -1, 20])
        cube([entreeL, epaisseur+2, entreeH]);
        
        translate([largeur/2 - entreeL/2, profondeur - epaisseur + 1, 200])
        cube([entreeL, epaisseur+5, entreeH]);
        
        translate([largeur/2 - entreeL/2, profondeur - epaisseur + 1, 100])
        cube([entreeL, epaisseur+5, entreeH]);
        
        translate([largeur/2 - entreeL/2, profondeur - epaisseur + 1, 20])
        cube([entreeL, epaisseur+5, entreeH]);
        
        translate([-1, profondeur/2 - entreeL/2, 20])
        cube([epaisseur+2, entreeL, entreeH]);  
        
        translate([largeur - epaisseur + 1, profondeur/2 - entreeL/2, 20])
        cube([epaisseur+5, entreeL, entreeH]);
        
        //deux fenetres
        translate([-1, profondeur/2 - fenetreL/2, 80])
        cube([epaisseur+2, fenetreL, fenetreH]);
        
        translate([largeur - epaisseur + 1, profondeur/2 - fenetreL/2, 80])
        cube([epaisseur + 5, fenetreL, fenetreH]);
    }
    
    //cadres des fenetres

    translate([0, profondeur/2 - fenetreL/2, 80])
    difference()
    {
        cube([fenetreEp, fenetreL, fenetreH]);

        translate([-1,5,5])
        cube([fenetreEp+2, fenetreL-10, fenetreH-10]);
    }
    
    translate([-fenetreEp, profondeur/2 - fenetreL/2, 80])
    cube([fenetreEp, fenetreL, fenetreH]);
    
    translate([largeur-fenetreEp, profondeur/2 - fenetreL/2, 80])
    difference()
    {
        cube([fenetreEp, fenetreL, fenetreH]);

        translate([-1,5,5])
        cube([fenetreEp+2, fenetreL-10, fenetreH-10]);
    }
    
    translate([largeur, profondeur/2 - fenetreL/2, 80])
    cube([fenetreEp, fenetreL, fenetreH]);
}
