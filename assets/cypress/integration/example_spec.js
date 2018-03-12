describe('Kitchen Sink', function () {
  it('.should() - assert that <title> is correct', function () {
    cy.visit('http://localhost:4001')
    cy.title().should('include', 'Kitchen Sink')
  })
})
