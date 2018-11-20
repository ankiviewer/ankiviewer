describe('Routes', () => {
  it('Home should have the correct <title>', () => {
    cy.visit('/');
    cy.title().should('include', 'Ankiviewer - Home');
    cy.get('.button-primary').should('contain', 'Sync Database');
  });

  it('Search should have the correct <title>', () => {
    cy.visit('/search');
    cy.title().should('include', 'Ankiviewer - Search');
    cy.get('button').should('contain', 'Edit columns');
  });

  it('Rules should have the correct <title>', () => {
    cy.visit('/rules');
    cy.title().should('include', 'Ankiviewer - Rules');
    cy.get('button').should('contain', 'Add New');
  })
});
