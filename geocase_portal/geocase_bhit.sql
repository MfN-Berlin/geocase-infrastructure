CREATE OR REPLACE VIEW full_rawdata AS
     SELECT 
          prov.providername,
          prov.providerurl,
          prov.provideraddress,
          prov.providercountry,
          source.name as sourceName,
          source.citation as sourceCitation,
          source.termsofuse as sourceTermsofuse,
          source.copyrights as sourceCopyrights,
          source.datasetowner,
          source.datasetownerabbrev,
          source.target_count,
          source.url as sourceURL,
          source.country as sourceCountry,
          source.hidden,
          `store`.unitid,
          `store`.collectioncode,
          `store`.institutioncode,
          `store`.accesspoint,
          occ.gatheringdate,
          occ.gatheringdatebegin,
          occ.gatheringdateend,
          occ.country,
          occ.isocountrycode,
          occ.locality,
          occ.collectornumber,
          occ.fieldnumber,
        --  occ.guid,
          occ.accessionnumber,
          occ.minDepth,
          occ.maxDepth,
          occ.minAltitude,
          occ.maxAltitude,
          occ.gatheringareas,
          occ.establishmentMeans,
          occ.recordURI,
          occ.water,
          ident.fullScientificName,
          ident.preferred,
          ident.isoBegin,
          ident.isoEnd,
          ident.dateText,
          ident.genusOrMonomial,
          ident.specificEpithet,
          ident.infraspecificEpithet,
          ident.infragenericEpithet,
          ident.mineral,
          higher.higherrank,
          higher.highertaxon,
          unitkind.kindofunit,
          strat.domain,
          strat.term,
          strat.sourcename as stratigraphySourceName,
          strat.sourcenameversion,
          strat.`comment`,
          strat.stratigraphytext,
          strat.stratigraphytype,
          media.type,
          media.format,
          media.sizeunit,
          media.`size`,
          Coalesce(media.url, "") as url,
          media.copyrights,
          media.termsofuse,
          media.licenses,
          media.relatedResource,
          prep.preparationdate,
          prep.preparationType,
          prep.preparationMaterials,
          prep.preparationStaff,


          CONCAT(COALESCE(prov.providername, ""), COALESCE(prov.provideraddress, ""), COALESCE(prov.providercountry, ""), COALESCE(`store`.collectioncode, ""), COALESCE(source.name, "")) as searchInstitution


     FROM rawoccurrence AS occ 
     JOIN bio_datasource as source ON occ.fk_datasourceid = source.id
     JOIN provider as prov ON source.fk_providerid = prov.providerid
     LEFT JOIN rawidentification AS ident ON ident.fk_occurrenceid = occ.occurrenceid
     LEFT JOIN identificationtohigher as identtohigher ON identtohigher.fk_rawidentificationid = ident.rawidentificationid
     LEFT JOIN rawhigher AS higher ON identtohigher.fk_highertaxaid = higher.highertaxaid
     LEFT JOIN unitkind ON occ.fk_kindofunitid = unitkind.unitkindid
     LEFT JOIN rawstratigraphy AS strat ON strat.fk_occurrenceid = occ.occurrenceid
     LEFT JOIN tripleidstore AS store ON occ.fk_tripleidstoreid = store.tripleidstoreid
     LEFT JOIN multimedia as media ON media.fk_tripleidstoreid = store.tripleidstoreid
     LEFT JOIN preparation as prep ON prep.fk_tripleidstoreid = store.tripleidstoreid

     WHERE ISNULL(source.hidden)

;
