describe('Search', () => {
  it('should behave as described', () => {
    cy.visit('/search');
    cy.get('#search-done').should('not.exist');
    cy.get('#search-edit_columns').should('contain', 'Edit columns');
    cy.get('#search-column_headers').should('not.exist');
    cy.get('#search-input').type('a')
    cy.get('#search-edit_columns').should('not.exist');
    cy.get('#search-column_headers > div').should('have.length', 12);
    cy.get('#search-result-rows > div').should('have.length', 4);
    cy.get('#search-result-rows > div').first().find('div').should('have.length', 12);
    cy.get('#search-input').type('{backspace}');
    cy.get('#search-column_headers').should('not.exist');
    cy.get('#search-edit_columns').should('contain', 'Edit columns').click();
    cy.get('#search-done').should('contain', 'Done');
    cy.get('#search-edit_columns').should('not.exist');

    cy
      .get('#search-columns_container > div')
      .should('have.length', 12)
      .each(($el) => {
        cy.wrap($el).should('have.class', 'green');
      });

    cy
      .get('#search-columns_container > div')
      .first()
      .click()

    cy
      .get('#search-columns_container > div')
      .should('have.length', 12)
      .each(($el, $index) => {
        if ($index === 0) {
          cy.wrap($el).should('not.have.class', 'green');
        } else {
          cy.wrap($el).should('have.class', 'green');
        }
      });

    cy.get('#search-done').click();
    cy.get('#search-done').should('not.exist');
    cy.get('#search-edit_columns').should('exist');
    cy.get('#search-input').type('a');
    cy.get('#search-edit_columns').should('not.exist');
    cy.get('#search-column_headers > div').should('have.length', 11);
    cy.get('#search-result-rows > div').should('have.length', 4);
    cy.get('#search-result-rows > div').first().find('div').should('have.length', 11);
  })
});
