describe('Routes', () => {
  it('Home should have the correct <title>', () => {
    cy.visit('/');
    cy.title().should('include', 'Ankiviewer - Home');
    cy.get('.nav-item.selected').should('contain', 'Home');
  });

  it('Search should have the correct <title>', () => {
    cy.visit('/search');
    cy.title().should('include', 'Ankiviewer - Search');
    cy.get('.nav-item.selected').should('contain', 'Search');
  });

  it('Rules should have the correct <title>', () => {
    cy.visit('/rules');
    cy.title().should('include', 'Ankiviewer - Rules');
    cy.get('.nav-item.selected').should('contain', 'Rules');
  })
});
