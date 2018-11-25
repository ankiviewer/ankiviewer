describe('Home', () => {
  it('should behave as described', () => {
    cy.visit('/');
    cy.get('#home-last_modified').should('contain', 'Last modified: Sat, 30th Dec 2017 at 17:40');
    cy.get('#home-number_notes').should('contain', 'Number notes: 10');
    cy.get('#home-sync_button').should('contain', 'Sync Database').click()
    cy.get('#home-sync_button', { timeout: 100 }).should('not.exist');
  });
});
