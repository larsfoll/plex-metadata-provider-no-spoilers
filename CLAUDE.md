# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a TypeScript-based Node.js project for creating a Plex-compatible Custom Metadata Provider using TheMovieDB (TMDB) as the data source. The provider implements the Plex Media Provider API specification to deliver metadata for movies, TV shows, seasons, and episodes.

## Architecture

### Plex Media Provider System

This project implements three core object models that work together:

1. **MediaProvider** (`docs/MediaProvider.md`): The root object that defines the provider's capabilities, supported metadata types (movies, shows, seasons, episodes), and available features (metadata retrieval, matching, collections).

2. **Metadata** (`docs/Metadata.md`): Complex JSON response schema for individual content items. Each metadata type (movie/show/season/episode) has:
   - Core attributes (ratingKey, guid, type, title, etc.)
   - Type-specific attributes (e.g., seasons/episodes have parent references)
   - Optional arrays (Image, Genre, Role, Director, Rating, etc.)
   - Hierarchical relationships via `Children` object for TV shows/seasons

3. **API Endpoints** (`docs/API Endpoints.md`): Defines three features:
   - **Metadata Feature**: GET endpoint to retrieve full metadata by ratingKey
   - **Match Feature**: POST endpoint to find matches based on contextual hints (title, year, filename, etc.)
   - **Collection Feature**: GET endpoint for retrieving collection metadata

### GUID System

All metadata items use a custom GUID format: `{scheme}://{metadataType}/{ratingKey}`

- Scheme must use prefix: `tv.plex.agents.custom.` followed by unique identifier
- Example: `tv.plex.agents.custom.johnz.tmdb://movie/tmdb-movie-19934`
- ratingKey uses only: `[a-zA-Z0-9_-]`

### Key Integration Points

- **External IDs**: Metadata should include `Guid` array with mappings to imdb, tmdb, tvdb for cross-provider compatibility
- **Localization**: Support `X-Plex-Language` and `X-Plex-Country` headers for region-specific content
- **TV Show Hierarchies**: Shows → Seasons → Episodes require proper parent/grandparent relationships with corresponding ratingKeys and GUIDs
- **Children Objects**: TV Shows and Seasons must support `includeChildren=1` parameter to return child metadata arrays
- **Episode Ordering**: Optional `episodeOrder` parameter for alternative season orderings (DVD, Airing, Absolute)

## Development Plan

Based on `checklist.txt`, the implementation follows this sequence:

1. Define MediaProvider model matching specification in `docs/MediaProvider.md`
2. Write unit tests for MediaProvider model
3. Define MetadataItem model matching specification in `docs/Metadata.md`
4. Write unit tests for Metadata model (all types: movie, show, season, episode)
5. Implement HTTP API endpoints for the three features
6. Create OpenAPI documentation from the markdown specs
7. Define '/library/metadata/:ratingKey/images` endpoint defined in docs/API Endpoints.md (Image endpoint (Recommended))
8. Define '/children' and '/grandchildren' Metadata endpoints defined in docs/API Endpoints.md (Children and Grandchildren Requests)
9. Implement TMDB "Episode Groups" which should be returned as "SeasonType" objects (defined in `docs/Metadata.md`) in TV Show Metadata.
10. Respect the `episodeOrder` query param for endpoints where Season objects are returned to return the correct ordering defined by the SeasonType/Episode Group.
11. Allow matching episodes by `date` param when `index` and `parentIndex` are no supplied (defined in `docs/API Endpoints.md`)
12. Log each request that is made to the TMDB API to the console, add an env variable to disable logging (enabled by default)
13. Log incoming requests to the console.

## Data Source

The provider fetches metadata from TheMovieDB.org API using Axios for HTTP requests. Key considerations:

- Map TMDB data structures to Plex-compatible Metadata format
- Handle image assets (TMDB provides base URLs + paths)
- Transform TMDB ratings to Plex Rating array format
- Map TMDB genre IDs to genre names
- Handle cast/crew data mapping to Role/Director/Writer/Producer arrays

## Testing Strategy

Unit tests must validate:
- MediaProvider schema compliance (identifier, Features array, Types array)
- Metadata schema compliance for each type with all required fields
- Type-specific attributes (e.g., parentGuid for seasons, grandparentGuid for episodes)
- GUID format validation
- Children object structure for hierarchical types
- Optional array structures (Image, Genre, Rating, etc.)
