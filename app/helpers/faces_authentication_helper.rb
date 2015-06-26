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
    namespace = 'Test2'
    findUid   = "all@#{namespace}"
    limite    = 70
    ids       = '' #Inicial variavel de retorno

    # varios uids e falha no na autenticação
    # json = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTg3MzYmY3ZxPW83NjkxMjNvcTgyMG4mZ3Z6cmZnbnpjPTIwMTUwNjA4MDQzMDA4","pid":"F@02e6947312b23fe46b8e834167761b1e_b769123bd820a","width":300,"height":150,"tags":[{"uids":[{"uid":"1@userAce","confidence":34},{"uid":"3@userAce","confidence":33},{"uid":"9@userAce","confidence":32},{"uid":"10@userAce","confidence":29},{"uid":"11@userAce","confidence":29},{"uid":"2@userAce","confidence":27}],"label":null,"confirmed":false,"manual":false,"width":25.33,"height":50.67,"yaw":0,"roll":-1,"pitch":0,"attributes":{"face":{"value":"true","confidence":54}},"points":null,"similarities":null,"tid":"TEMP_F@02e6947312b23fe46b8e83410078005c_b769123bd820a_40.00_61.33_0_1","recognizable":true,"threshold":59,"center":{"x":40,"y":61.33},"eye_left":{"x":46.67,"y":48.67,"confidence":53,"id":449},"eye_right":{"x":34.67,"y":49.33,"confidence":30,"id":450},"mouth_center":{"x":40,"y":75.33,"confidence":29,"id":615},"nose":{"x":40,"y":62.67,"confidence":54,"id":403}}]}],"usage":{"used":27,"remaining":73,"limit":100,"reset_time":1433741397,"reset_time_text":"Mon, 8 June 2015 05:29:57 +0000"},"operation_id":"36562d316152433da59ad123d4a4ea51"}'
    # autenticado
    # json = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTU5NTAmY3ZxPTFwN3NzcHFvN3ByOTcmZ3Z6cmZnbnpjPTIwMTUwNjA4MDIxMTIx","pid":"F@0ea4d5b50ca02f32220169f701de419a_1c7ffcdb7ce97","width":300,"height":150,"tags":[{"uids":[{"uid":"123@Test2","confidence":65},{"uid":"alisson@Test2","confidence":64}],"label":null,"confirmed":false,"manual":false,"width":18.33,"height":36.67,"yaw":24,"roll":4,"pitch":0,"attributes":{"face":{"value":"true","confidence":56}},"points":null,"similarities":null,"tid":"TEMP_F@0ea4d5b50ca02f32220169f7009c0063_1c7ffcdb7ce97_52.00_66.00_0_1","recognizable":true,"threshold":60,"center":{"x":52.0,"y":66.0},"eye_left":{"x":54.0,"y":58.0,"confidence":54,"id":449},"eye_right":{"x":45.33,"y":56.0,"confidence":54,"id":450},"mouth_center":{"x":48.67,"y":76.0,"confidence":28,"id":615},"nose":{"x":49.0,"y":66.0,"confidence":53,"id":403}}]}],"usage":{"used":27,"remaining":73,"limit":100,"reset_time":1433734197,"reset_time_text":"Mon, 8 June 2015 03:29:57 +0000"},"operation_id":"c6882f4eed1447c998fdeded25f144b9"}'
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

    # Sem tags
    # json = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTI1ODgmY3ZxPXI3MTg1b3EzbnI0MDQmZ3Z6cmZnbnpjPTIwMTUwNjA2MDAxOTQ4","pid":"F@0d805a8b7e8a20ae06a427821a663dae_e7185bd3ae404","width":300,"height":150,"tags":[]}],"usage":{"used":1,"remaining":99,"limit":100,"reset_time":1433550597,"reset_time_text":"Sat, 6 June 2015 00:29:57 +0000"},"operation_id":"65ea78fab63f4ec99fb3dd1a1f43cb61"}'
    # Uma tag
    # json = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTk2OTUmY3ZxPTY2cDY1NDQ3NjBzMTYmZ3Z6cmZnbnpjPTIwMTUwNjA1MDE0NzUz","pid":"F@0da7f39f3e72abe16a1af9685812c4ab_66c6544760f16","width":300,"height":150,"tags":[{"uids":[],"label":null,"confirmed":false,"manual":false,"width":18.0,"height":36.0,"yaw":24,"roll":6,"pitch":0,"attributes":{"face":{"value":"true","confidence":60}},"points":null,"similarities":null,"tid":"TEMP_F@0da7f39f3e72abe16a1af968009c005d_66c6544760f16_52.00_62.00_0_1","recognizable":true,"center":{"x":52.0,"y":62.0},"eye_left":{"x":54.0,"y":54.0,"confidence":52,"id":449},"eye_right":{"x":45.0,"y":51.33,"confidence":54,"id":450},"mouth_center":{"x":48.0,"y":72.67,"confidence":47,"id":615},"nose":{"x":48.67,"y":62.0,"confidence":54,"id":403}}]}],"usage":{"used":10,"remaining":90,"limit":100,"reset_time":1433474997,"reset_time_text":"Fri, 5 June 2015 03:29:57 +0000"},"operation_id":"75f8167817724037900c2614a9e4998d"}'
    # Varias tags
    # json = JSON.parse '{"status":"success","photos":[{"url":"https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/p180x540/10256530_691954754174414_3884376225325975480_n.jpg?oh=fe957fa01553d0ba28612a04d915e74a&oe=55A8C1B1&__gda__=1436997505_83f78977f7487f9cd931f94d750b3159","pid":"F@0e98aa825ccca4d04c695bbe7231b30c_20b6dc66a738e","width":720,"height":540,"tags":[{"uids":[{"uid":"marcelo@Test2","confidence":49}],"label":null,"confirmed":false,"manual":false,"width":7.22,"height":9.63,"yaw":-27,"roll":0,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe009a00de_20b6dc66a738e_21.39_41.11_0_1","recognizable":true,"threshold":52,"center":{"x":21.39,"y":41.11},"eye_left":{"x":24.17,"y":38.7,"confidence":53,"id":449},"eye_right":{"x":20.69,"y":38.33,"confidence":52,"id":450},"mouth_center":{"x":22.5,"y":43.52,"confidence":25,"id":615},"nose":{"x":22.64,"y":41.48,"confidence":55,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":40}],"label":null,"confirmed":false,"manual":false,"width":6.39,"height":8.52,"yaw":-27,"roll":5,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe010100b8_20b6dc66a738e_35.69_34.07_0_1","recognizable":true,"threshold":52,"center":{"x":35.69,"y":34.07},"eye_left":{"x":38.33,"y":32.41,"confidence":52,"id":449},"eye_right":{"x":35.14,"y":32.22,"confidence":51,"id":450},"mouth_center":{"x":36.67,"y":36.48,"confidence":53,"id":615},"nose":{"x":36.94,"y":34.81,"confidence":56,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":47}],"label":null,"confirmed":false,"manual":false,"width":6.53,"height":8.7,"yaw":2,"roll":-5,"pitch":0,"attributes":{"face":{"value":"true","confidence":73}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe0164008b_20b6dc66a738e_49.44_25.74_0_1","recognizable":true,"threshold":52,"center":{"x":49.44,"y":25.74},"eye_left":{"x":50.83,"y":23.15,"confidence":54,"id":449},"eye_right":{"x":47.36,"y":23.7,"confidence":50,"id":450},"mouth_center":{"x":49.44,"y":28.15,"confidence":54,"id":615},"nose":{"x":49.31,"y":26.48,"confidence":57,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":100}],"label":null,"confirmed":true,"manual":false,"width":6.94,"height":9.26,"yaw":16,"roll":-8,"pitch":0,"attributes":{"face":{"value":"true","confidence":77}},"points":null,"similarities":null,"tid":"01d400af_20b6dc66a738e","recognizable":true,"threshold":52,"center":{"x":65,"y":32.41},"eye_left":{"x":65.97,"y":29.63,"confidence":53,"id":449},"eye_right":{"x":62.5,"y":30.19,"confidence":52,"id":450},"mouth_center":{"x":64.31,"y":35,"confidence":53,"id":615},"nose":{"x":64.31,"y":33.15,"confidence":58,"id":403}}]}],"usage":{"used":6,"remaining":94,"limit":100,"reset_time":1428388197,"reset_time_text":"Tue, 7 April 2015 06:29:57 +0000"},"operation_id":"0227947c12914f6793bdcec36ab33bb0"}'
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

    namespace = 'Test2'
    uid = "#{id}@#{namespace}"

    # tagsSave = JSON.parse '{"status":"success","saved_tags":[{"tid":"009c005d_66c6544760f16","detected_tid":"TEMP_F@0da7f39f3e72abe16a1af968009c005d_66c6544760f16_52.00_62.00_0_1"}],"message":"Tag saved with uid: 1@userAce, label: ","operation_id":"622839020ebb4027ac848d315130bafc"}'
    tagsSave = face.tags_save(:uid => uid, :tids => tid)

    # verifica resposta de tagsSave
    if !JsonPath.on(tagsSave, '$.saved_tags').blank?
      # facesTrain = JSON.parse '{"status":"success","created":[{"uid":"1@userAce","training_set_size":1,"last_trained":1433557791,"training_in_progress":false}],"operation_id":"bdb679e7dc4a4df4aa1b51f7eb700972"}'
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
    Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')
  end
end
