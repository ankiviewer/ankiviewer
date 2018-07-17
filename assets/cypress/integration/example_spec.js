describe('Ankiviewer', () => {
  it('should have correct <title>', () => {
    cy.visit('/');
    cy.title().should('include', 'Hello AnkiViewer!');
  });

  it('.should have correct <title', () => {
    cy.visit('/search');
    cy.title().should('include', 'Hello AnkiViewer!');
  });
});
