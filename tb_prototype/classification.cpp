#include "classification.h"

TypeInsecte classifierSon(CaracteristiquesSon son)
{
    // Bruit très violent
    if(son.maximum > 1500 && son.nombrePics > 8)
    {
        return BRUIT_PARASITE;
    }
    // Son régulier d'insecte
    if(son.moyenne > 100 && son.moyenne < 800 && son.variation < 120 && son.nombrePics < 5)
    {
        return POLLINISATEUR;
    }
    // Sinon
    return AUCUN;
}