#!/bin/bash

# Script pour générer les images PlantUML
# Nécessite d'avoir PlantUML installé : sudo apt-get install plantuml
# Ou télécharger plantuml.jar depuis http://plantuml.com/download

echo "Génération des diagrammes PlantUML..."

# Répertoire des diagrammes
DIAGRAM_DIR="diagrams"
OUTPUT_DIR="diagrams/images"

# Créer le répertoire de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

# Générer les images pour chaque fichier .puml
for puml_file in "$DIAGRAM_DIR"/*.puml; do
    if [ -f "$puml_file" ]; then
        echo "Génération de $(basename "$puml_file")..."
        
        # Utiliser PlantUML pour générer l'image
        # Option 1 : Si plantuml est installé
        # plantuml -tpng -o "$OUTPUT_DIR" "$puml_file"
        
        # Option 2 : Si vous avez plantuml.jar
        # java -jar plantuml.jar -tpng -o "$OUTPUT_DIR" "$puml_file"
        
        # Option 3 : Utiliser le serveur PlantUML en ligne
        filename=$(basename "$puml_file" .puml)
        curl -s "http://www.plantuml.com/plantuml/png/$(cat "$puml_file" | plantuml -encodeuml)" > "$OUTPUT_DIR/$filename.png"
    fi
done

echo "Génération terminée. Images sauvegardées dans $OUTPUT_DIR/"