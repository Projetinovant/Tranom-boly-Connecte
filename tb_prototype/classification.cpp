#include "classification.h"

TypeInsecte classifierSon(Caracteristiques son)
{
    if(son.maximum > 2000 && son.nombrePics > 15)
    {
        return BRUIT_PARASITE;
    }
    if(son.moyenne > 150 && son.moyenne < 600 && son.variation < 100 && son.nombrePics > 3 && son.nombrePics < 10)
    {
        return POLLINISATEUR;
    }
    return AUCUN;
}
