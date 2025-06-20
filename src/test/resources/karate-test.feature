@HU-001
Feature: Test de API Marvel Characters

  Background:
    * configure ssl = true
    * def random = java.util.UUID.randomUUID().toString().substring(0, 10)
    * def baseUrl = 'http://localhost:8080/vycarden/api/characters'
    * def nombreUnico = "Iron Man " + random
    * def personaje = { name: '#(nombreUnico)', alterego: 'Tony Stark', description: 'Genius billionaire', powers: ['Armor', 'Flight'] }
    * def personajeActualizado = { name: '#(nombreUnico)', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }

  @id:1
  Scenario: T-API-HU-001-CA1-Obtener todos los personajes
    Given url baseUrl
    When method get
    Then status 200
    And match response == '#[]'

  @id:2
  Scenario: T-API-HU-001-CA2-Crear personaje (exitoso)
    Given url baseUrl
    And request personaje
    And header Content-Type = 'application/json'
    When method post
    Then status 201
    And match response contains personaje

  @id:3
  Scenario: T-API-HU-001-CA3-Obtener personaje por ID (exitoso), despues de crearlo
    Given url baseUrl
    And request personaje
    And header Content-Type = 'application/json'
    When method post
    * def idPersonaje = response.id
    Given url baseUrl + '/' + idPersonaje
    When method get
    Then status 200
    And match response.name == personaje.name
    And match response.alterego == personaje.alterego
    And match response.description == personaje.description
    And match response.powers == personaje.powers

  @id:4
  Scenario: T-API-HU-001-CA4-Obtener personaje por ID (no existe)
    Given url baseUrl + '/999'
    When method get
    Then status 404
    And match response == { error: 'Character not found' }


  @id:5
  Scenario: T-API-HU-001-CA5-Crear personaje (nombre duplicado)
    Given url baseUrl
    And request { name: 'Iron Man', alterego: 'Otro', description: 'Otro', powers: ['Armor'] }
    And header Content-Type = 'application/json'
    When method post
    Then status 400
    And match response == { error: 'Character name already exists' }

  @id:6
  Scenario: T-API-HU-001-CA6-Crear personaje (faltan campos requeridos)
    Given url baseUrl
    And request { name: '', alterego: '', description: '', powers: [] }
    And header Content-Type = 'application/json'
    When method post
    Then status 400
    And match response == { name: 'Name is required', alterego: 'Alterego is required', description: 'Description is required', powers: 'Powers are required' }


  @id:7
  Scenario: T-API-HU-001-CA7-Actualizar personaje (exitoso), después de haberlo creado
    Given url baseUrl
    And request personaje
    And header Content-Type = 'application/json'
    When method post
    * def idPersonaje = response.id
    Given url baseUrl + '/' + idPersonaje
    And request personajeActualizado
    And header Content-Type = 'application/json'
    When method put
    Then status 200
    And match response.name == personajeActualizado.name
    And match response.description == personajeActualizado.description


  @id:3
  Scenario: T-API-HU-001-CA8-Actualizar personaje (no existe)
    Given url baseUrl + '/999'
    And request { name: 'Iron Man', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    And header Content-Type = 'application/json'
    When method put
    Then status 404
    And match response == { error: 'Character not found' }

  @id:9
  Scenario: T-API-HU-001-CA9-Eliminar personaje (exitoso), después de haberlo creado
    Given url baseUrl
    And request personaje
    And header Content-Type = 'application/json'
    When method post
    * def idPersonaje = response.id
    Given url baseUrl + '/'+idPersonaje
    When method delete
    Then status 204
    And match response == ''

  @id:10
  Scenario: T-API-HU-001-CA10-Eliminar personaje (no existe)
    Given url baseUrl + '/999'
    When method delete
    Then status 404
    And match response == { error: 'Character not found' }
