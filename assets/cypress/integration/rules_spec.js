describe('Rules', () => {
  beforeEach(() => {
    return cy.request('/api/rules')
      .then((response) => Promise.all(
        response.body.rules.map((rule) => {
          return cy.request('DELETE', '/api/rules/' + rule.rid);
        })
      ))
  });

  it('should behave as expected', () => {
    cy.server();
    cy.route('GET', '/api/rules').as('getRules');
    cy.route('POST', '/api/rules').as('postRules');

    cy.visit('/rules');
    cy.wait('@getRules');
    cy.get('#rules-rules_container > div').should('have.length', 0);
    cy.get('.red').should('have.length', 0);
    cy.get('#rules-add_new')
      .should('contain', 'Add New')
      .click({ force: true }); // open issue for needing to use force: true here - https://github.com/cypress-io/cypress/issues/695
    cy.wait('@postRules');
    cy.get('.red')
      .should('have.length', 3)
      .each(($el) => {
        cy.wrap($el).should('contain', 'can\'t be blank')
      });

    cy.get('#rules-input_name').type('no empty sfld', { force: true });
    cy.get('.red').should('have.length', 0);
    cy.get('#rules-add_new').click({ force: true })
    cy.wait('@postRules');
    cy.get('.red')
      .should('have.length', 2)
      .each(($el) => {
        cy.wrap($el).should('contain', 'can\'t be blank')
      });
    cy.get('#rules-input_name').should('have.value', 'no empty sfld');
    cy.get('#rules-input_code').type('a', { force: true });
    cy.get('#rules-add_new').click({ force: true })
    cy.wait('@postRules');
    cy.get('.red')
      .should('have.length', 2)
      .each(($el, $i) => {
        if ($i === 0) {
          cy.wrap($el).should('contain', 'undefined function a/0');
        } else {
          cy.wrap($el).should('contain', 'can\'t be blank')
        }
      });

    cy.get('#rules-input_code').type('{backspace}card.sfld != ""', { force: true });
    cy.get('#rules-add_new').click({ force: true });
    cy.wait('@postRules');
    cy.get('#rules-input_tests').type('[]', { force: true });
    cy.get('#rules-add_new').click({ force: true });
    cy.wait('@postRules');
    cy.get('#rules-input_name').should('have.value', '');
    cy.get('#rules-input_code').should('have.value', '');
    cy.get('#rules-input_tests').should('have.value', '');
    cy.get('#rules-rules_container > div')
      .should('have.length', 1)
      .first()
      .should('contain', 'no empty sfld')
      .click({ force: true });
    cy.get('#rules-input_name').should('have.value', 'no empty sfld');
    cy.get('#rules-input_code').should('have.value', 'card.sfld != ""');
    cy.get('#rules-input_tests').should('have.value', '[]');

    cy.get('#rules-add_new').should('not.be.visible');
    cy.get('#rules-update_rule').should('contain', 'Update Rule');
    cy.get('#rules-delete_rule').should('contain', 'Delete Rule');
    cy.get('#rules-run_rule').should('contain', 'Run Rule');
  });
});
