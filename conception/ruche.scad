$fn = 80;

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
entreeH = 15;
union()
{
    //toit 
    
    //corps
    difference()
    {
        cube([largeur,profondeur,hauteur]);
        
        translate([epaisseur, epaisseur, epaisseur])
        cube([largeur-2*epaisseur, profondeur-2*epaisseur, hauteur]);
        
        translate([largeur/2 - entreeL/2, -1, 20])
        cube([entreeL, epaisseur+2, entreeH]);
        
        translate([largeur/2 - entreeL/2, profondeur - epaisseur + 1, 20])
        cube([entreeL, epaisseur+5, entreeH]);

        translate([-1, profondeur/2 - entreeL/2, 20])
        cube([epaisseur+2, entreeL, entreeH]);  
        
        translate([largeur - epaisseur + 1, profondeur/2 - entreeL/2, 20])
        cube([epaisseur+5, entreeL, entreeH]);
        
        translate([largeur/2 - fenetreL/2, -1, 80])
        cube([fenetreL, epaisseur+2, fenetreH]);
        
        translate([largeur/2 - fenetreL/2, profondeur - epaisseur+1, 80])
        cube([fenetreL, epaisseur+5,fenetreH]);
        
        translate([-1, profondeur/2 - fenetreL/2, 80])
        cube([epaisseur+2, fenetreL, fenetreH]);
        
        translate([largeur - epaisseur + 1, profondeur/2 - fenetreL/2, 80])
        cube([epaisseur + 5, fenetreL, fenetreH]);
    }
}
