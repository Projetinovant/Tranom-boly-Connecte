#ifndef CLASSIFICATION_H
#define CLASSIFICATION_H

#include "analyse.h"
enum TypeInsecte
{
    AUCUN,
    POLLINISATEUR,
    AUXILIAIRE,
    BRUIT_PARASITE
};

TypeInsecte classifierSon(Caracteristiques son);

#endif
