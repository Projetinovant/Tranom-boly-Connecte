#ifndef CLASSIFICATION_H
#define CLASSIFICATION_H

#include "analyseSon.h"
enum TypeInsecte
{
    AUCUN,
    POLLINISATEUR,
    AUXILIAIRE,
    BRUIT_PARASITE
};

TypeInsecte classifierSon(CaracteristiquesSon son);

#endif