CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100),
    scientific_name VARCHAR(150),
    discovery_date DATE,
    conservation_status VARCHAR(50)
);

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    species_id INT REFERENCES species(species_id),
    ranger_id INT REFERENCES rangers(ranger_id),
    location VARCHAR(100),
    sighting_time TIMESTAMP,
    notes TEXT
);



INSERT INTO rangers (ranger_id, name, region) VALUES
(1, 'Alice Green', 'Northern Hills'),
(2, 'Bob White', 'River Delta'),
(3, 'Carol King', 'Mountain Range'),
(4, 'David Lin', 'Rainforest Edge'),
(5, 'Elena Cruz', 'Dry Savannah'),
(6, 'Frank Njoroge', 'River Delta'),
(7, 'Gita Patel', 'Mountain Range'),
(8, 'Hassan Ali', 'Northern Hills');

SELECT * from rangers;

INSERT INTO species (species_id, common_name, scientific_name, discovery_date, conservation_status) VALUES
(1, 'Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
(2, 'Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
(3, 'Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
(4, 'Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered'),
(5, 'Shadow Leopard', 'Panthera nebulosa umbra', '1965-06-20', 'Critically Endangered'),
(6, 'Golden Langur', 'Trachypithecus geei', '1950-03-12', 'Endangered'),
(7, 'Giant Hornbill', 'Buceros bicornis', '1786-08-15', 'Vulnerable'),
(8, 'Indian Pangolin', 'Manis crassicaudata', '1822-09-30', 'Endangered'),
(9, 'Black Stork', 'Ciconia nigra', '1758-01-01', 'Near Threatened');

SELECT * from species;



INSERT INTO sightings (sighting_id, species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(4, 1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL),
(5, 5, 4, 'Umbra Ravine', '2024-05-20 06:50:00', 'Tracks and fur tufts found'),
(6, 6, 5, 'Canopy Trail', '2024-05-22 11:00:00', 'Small group observed in trees'),
(7, 7, 6, 'High Nest Cliffs', '2024-05-23 14:35:00', 'Loud calls and nest spotted'),
(8, 8, 7, 'Burrow Valley', '2024-05-23 19:00:00', 'Fresh burrow found'),
(9, 9, 8, 'Lake Haven', '2024-05-24 06:30:00', 'Single bird at shoreline');

SELECT * from sightings;


--1️⃣ Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'

INSERT INTO rangers (ranger_id, name, region) VALUES
( 9, 'Derek Fox', 'Coastal Plains');



--2️⃣ Count unique species ever sighted.


SELECT DISTINCT count(scientific_name) as unique_species_count FROM species;


--3️⃣Find all sightings where the location includes "Pass".


SELECT * from sightings  
WHERE location ILIKE '%pass';


--4️⃣List each ranger's name and their total number of sightings.

SELECT rangers.name, count(sightings.ranger_id) as total_sightings from rangers 
JOIN sightings ON sightings.ranger_id = rangers.ranger_id 
GROUP BY rangers.name 
ORDER BY rangers.name ASC;



--5️⃣List species that have never been sighted.

SELECT common_name FROM species
    WHERE NOT EXISTS (
        SELECT 1 FROM sightings where sightings.species_id = species.species_id);


--6️⃣ Show the most recent 2 sightings.

SELECT species.common_name, sightings.sighting_time, rangers.name  FROM sightings
JOIN species ON species.species_id = sightings.ranger_id 
JOIN rangers ON rangers.ranger_id = sightings.ranger_id 
ORDER BY sighting_time DESC
LIMIT 2;




--7️⃣ Update all species discovered before year 1800 to have status 'Historic'.
    
    UPDATE species SET conservation_status = 'Historic' WHERE EXTRACT(YEAR FROM discovery_date::DATE)<1800;



--8️⃣ Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.


SELECT sighting_id,
case 
WHEN EXTRACT(HOUR FROM sighting_time) BETWEEN 5 AND 11 THEN 'Morning'
WHEN EXTRACT(HOUR FROM sighting_time) BETWEEN 12 AND 17 THEN 'Afternoon'
ELSE 'Evening'
END AS time_of_day
FROM sightings;


--9️⃣ Delete rangers who have never sighted any species

CREATE Procedure delete_rangers_without_sightings()
LANGUAGE plpgsql
AS $$
BEGIN
DELETE FROM rangers
    WHERE NOT EXISTS (
        SELECT 1 
        FROM sightings 
        where sightings.ranger_id = rangers.ranger_id
    );
END;
$$;


CALL delete_rangers_without_sightings()