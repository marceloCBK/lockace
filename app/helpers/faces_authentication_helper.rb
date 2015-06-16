module FacesAuthenticationHelper
  # before_action :face_conection

  def getTags json
    # seleciona tags detectadas
    # obs.: "first" foi usado pois o resultado de JsonPath para argumetos com ".." fica em um array
    tags = JsonPath.on(json, "$.photos..tags").first
    @relatorio << [mensagem: 'Não foi possível detectar sua face!', erros:[tags: tags], json: json] if tags.blank?

    # retorno
    tags
  end

  # Encontra qual tag detectata com maior confiança (confidence)
  # Caso existam mais de uma com o valor de qualidade maxima, apenas a primeira sera usada
  def getTagMax json, limite, path=''

    # c = confidences
    c = JsonPath.on(json, "$#{path}..confidence")

    # define o valor mais alto entre as "confidence" das tags identificadas
    if c.is_a? Integer
      maximo = c
    elsif c.is_a? Array
      maximo = c.max
    end

    aprovada = maximo.to_i >= limite
    if aprovada
      c = c.index(maximo)
      tag = json[c]
    end unless c.blank? # não faça caso "c" esteja vazio
    @relatorio << [
        mensagem: 'Essa foto não ficou boa, que tentar novamente?',
        erros: [certeza: maximo, limite: limite],
        json: json
    ] unless aprovada

    # retorno
    tag
  end

  def reconhecer

    url       = params[:urlFace]
    namespace = 'userAce'
    findUid   = "all@#{namespace}"
    limite    = 70
    ids       = '' #Inicial variavel de retorno

    #Envia dados sobre a imagem
    json = face.faces_recognize(:uids => findUid, :urls => url) unless url.blank?


    # Encontra tags no json recebido
    tags = getTags json unless json.blank?

    if !tags.blank?

      # Encontra uids nas tags
      uidsAll = JsonPath.on(tags, "$..uids").first

      # verifica se existe algum uid
      unless uidsAll.blank?
        tags.each do |tag|
          # Encontra uids desta tag
          uids = JsonPath.on(tag, "$..uids").first
          # Enconta tid desta tag
          tid  = JsonPath.on(tag, "$.tid")

          # TODO Decidir se remove ou não a menssagem em "getTagMax" com "unless uids.blank?"
          # Encontra uid com maior confiança (confidence)
          usuario = getTagMax uids, limite

          # Encontra o uid nos dados do usuário encontrado acima
          uid = JsonPath.on(usuario, "$.uid").first unless usuario.blank?
          ids = [tid: tid, uid: uid, usuario: usuario, uids: uids]
        end
      else
        @relatorio << [
            mensagem: 'Usuário não encontrado! Já fez seu cadastro?',
            erros: ["nenhum uid"],
            json: json
        ]
      end

    end
    @response = [tags: tags.blank?,useFaces: params[:useFace], ids: ids, json: json] #  , tags: tags

    # retorno
    ids

  end

  def detectar

    url = params[:urlFace]
    limite = 50

    #Envia dados sobre a imagem
    json = face.faces_detect(:urls => url) unless url.blank?


    # seleciona tags detectadas
    tags = getTags json unless json.blank?

    if !tags.blank?

      # Encontra tag com maior confiança (confidence)
      tag = getTagMax tags, limite, '..face'

      # Encontra o tid nos dados do rosto encontrado acima
      tid = JsonPath.on(tag, "$.tid").first unless tag.blank?

    end

    # retorno
    tid

  end

  def cadastrar tid, id

    namespace = 'userAce'
    uid = "#{id}@#{namespace}"

    # Envia dados para criação das tags
    tagsSave = face.tags_save(:uid => uid, :tids => tid)


    # verifica resposta de tagsSave
    if !JsonPath.on(tagsSave, '$.saved_tags').blank?
      facesTrain = face.faces_train(:uids => id, :namespace  => namespace)
    end

    @relatorio << [
        mensagem: 'Não foi possível melhorar sua face!',
        erros: ['unchanged'],
        facesTrain: facesTrain
    ] unless JsonPath.on(facesTrain, '$.unchanged').blank?



    # Preparando retorno
    result = JsonPath.on(facesTrain, '$.created')
    tipo   = "created" unless result.blank?

    if result.blank?
      result = JsonPath.on(facesTrain, '$.updated')
      tipo   = "updated" unless result.blank?
    end

    if result.blank?
      result = JsonPath.on(facesTrain, '$.unchanged')
      tipo   = "unchanged" unless result.blank?
    end

    # retorno
    retorno = [tipo: tipo, result: result]

  end


  private

  def face
    Face.get_client(:api_key => 'insira_aqui_seu_api_key', :api_secret => 'insira_aqui_seu_api_secret')
  end
end
