import { AnagraficaPage } from './app.po';

describe('anagrafica App', () => {
  let page: AnagraficaPage;

  beforeEach(() => {
    page = new AnagraficaPage();
  });

  it('should display welcome message', done => {
    page.navigateTo();
    page.getParagraphText()
      .then(msg => expect(msg).toEqual('Welcome to app!!'))
      .then(done, done.fail);
  });
});
