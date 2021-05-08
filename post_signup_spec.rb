require_relative "routes/signup"
require_relative "libs/mongo"

describe "POST /signup" do
    context "Novo usuario" do
        before(:all) do
            payload = { name: "Pitty", email: "pitty@bol.com", password: "123" }
            MongoDB.new.remove_user(payload[:email])

            @result = Signup.new.create(payload)
        end

        it "Valida status code 200" do
            expect(@result.code).to eql 200
        end

        it "Valida tamanho do id do usuario" do
        expect(@result.parsed_response["_id"].length).to eql 24
        end
    end

    context "E-mail ja existente" do
        # dado que eu tenha um novo usuario 
    before(:all) do
    payload = { name: "Maria", email: "maria@bol.com", password: "12345" }
    MongoDB.new.remove_user(payload[:email])

    # e o email desse usuario ja foi cadastrado no sistema
    Signup.new.create(payload)

    # quando faço uma requisicao para a rota /signup
    @result = Signup.new.create(payload)
    end
    
    it "Valida status code 409" do
        # entao deve retornar 409
        expect(@result.code).to eql 409
    end

    it "Valida mensagem de e-mail ja existente" do
        expect(@result.parsed_response["error"]).to eql "Email already exists :("
        end
    end

    #campos obrigatorios = name, email e password

examples = [
         {
             title: "Nome em branco",
             payload: { name: "", email: "maria@bol.com", password: "12345" },
             code: 412,
             error: "required name",
         },
         {
             title: "Sem campo nome",
             payload: { email: "maria@bol.com", password: "12345" },
             code: 412,
             error: "required name",
         },
         {
             title: "E-mail invalido",
             payload: { name: "Maria", email: "maabol.com", password: "12345" },
             code: 412,
             error: "wrong email",
         },
         {
             title: "Campo e-mail em branco",
             payload: { name: "Maria", email: "", password: "12345" },
             code: 412,
             error: "required email",
         },
         {
             title: "Sem campo e-mail",
             payload: { name: "Maria", password: "12345" },
             code: 412,
             error: "required email",
         },
         {
             title: "Campo senha em branco",
             payload: { name: "Maria", email: "maria@bol.com", password: "" },
             code: 412,
             error: "required password",
         },
         {
              title: "Sem campo senha",
             payload: { name: "Maria", email: "maria@bol.com" },
              code: 412,
              error: "required password",
         },
     ]
    examples.each do |e| 
        context "#{e[:title]}" do
            before(:all) do
                @result = Signup.new.create(e[:payload])
            end
    
            it "Valida status code #{e[:code]}" do
                expect(@result.code).to eql e[:code] 
            end
    
            it "Valida mensagem de erro" do
            expect(@result.parsed_response["error"]).to eql e[:error]
             end
        end
    end
end
