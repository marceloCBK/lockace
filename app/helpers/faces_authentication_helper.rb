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
  def getTagMax json, limite

    # c = confidences
    c = JsonPath.on(json, "$..confidence")

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

    face = Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')

    url = params[:urlFace]
    namespace = 'userAce'
    findUid = "all@#{namespace}"

    # varios uids e falha no na autenticação
    # json = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTg3MzYmY3ZxPW83NjkxMjNvcTgyMG4mZ3Z6cmZnbnpjPTIwMTUwNjA4MDQzMDA4","pid":"F@02e6947312b23fe46b8e834167761b1e_b769123bd820a","width":300,"height":150,"tags":[{"uids":[{"uid":"1@userAce","confidence":34},{"uid":"3@userAce","confidence":33},{"uid":"9@userAce","confidence":32},{"uid":"10@userAce","confidence":29},{"uid":"11@userAce","confidence":29},{"uid":"2@userAce","confidence":27}],"label":null,"confirmed":false,"manual":false,"width":25.33,"height":50.67,"yaw":0,"roll":-1,"pitch":0,"attributes":{"face":{"value":"true","confidence":54}},"points":null,"similarities":null,"tid":"TEMP_F@02e6947312b23fe46b8e83410078005c_b769123bd820a_40.00_61.33_0_1","recognizable":true,"threshold":59,"center":{"x":40,"y":61.33},"eye_left":{"x":46.67,"y":48.67,"confidence":53,"id":449},"eye_right":{"x":34.67,"y":49.33,"confidence":30,"id":450},"mouth_center":{"x":40,"y":75.33,"confidence":29,"id":615},"nose":{"x":40,"y":62.67,"confidence":54,"id":403}}]}],"usage":{"used":27,"remaining":73,"limit":100,"reset_time":1433741397,"reset_time_text":"Mon, 8 June 2015 05:29:57 +0000"},"operation_id":"36562d316152433da59ad123d4a4ea51"}'
    # autenticado
    # json = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTU5NTAmY3ZxPTFwN3NzcHFvN3ByOTcmZ3Z6cmZnbnpjPTIwMTUwNjA4MDIxMTIx","pid":"F@0ea4d5b50ca02f32220169f701de419a_1c7ffcdb7ce97","width":300,"height":150,"tags":[{"uids":[{"uid":"123@Test2","confidence":65},{"uid":"alisson@Test2","confidence":64}],"label":null,"confirmed":false,"manual":false,"width":18.33,"height":36.67,"yaw":24,"roll":4,"pitch":0,"attributes":{"face":{"value":"true","confidence":56}},"points":null,"similarities":null,"tid":"TEMP_F@0ea4d5b50ca02f32220169f7009c0063_1c7ffcdb7ce97_52.00_66.00_0_1","recognizable":true,"threshold":60,"center":{"x":52.0,"y":66.0},"eye_left":{"x":54.0,"y":58.0,"confidence":54,"id":449},"eye_right":{"x":45.33,"y":56.0,"confidence":54,"id":450},"mouth_center":{"x":48.67,"y":76.0,"confidence":28,"id":615},"nose":{"x":49.0,"y":66.0,"confidence":53,"id":403}}]}],"usage":{"used":27,"remaining":73,"limit":100,"reset_time":1433734197,"reset_time_text":"Mon, 8 June 2015 03:29:57 +0000"},"operation_id":"c6882f4eed1447c998fdeded25f144b9"}'
    json = face.faces_recognize(:uids => findUid, :urls => url) unless url.blank?


    # Encontra tags no json recebido
    tags = getTags json

    if !tags.blank?

      # Encontra uids nas tags
      uids = JsonPath.on(json, "$..uids").first
      @relatorio << [
          mensagem: 'Usuário não encontrado! Já fez seu cadastro?',
          erros: ["nenhum uid"],
          json: json
      ] if uids.blank?

      # Encontra tag com maior confiança (confidence) e seu valor minimo
      usuario = getTagMax uids, 50

      # Encontra o uid nos dados do usuário encontrado acima
      uid = JsonPath.on(usuario, "$.uid").first unless usuario.blank?

      # seleciona id de usuário
      id  = uid.split("@").first unless uid.blank?
    end

    @response = [useFaces: params[:useFace], id: id, uid: uid, usuario: usuario, uids: uids, json: json] #  , tags: tags

    # retorno
    id
  end

  def detectar
    face = Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')

    url = params[:urlFace]
    limite = 50

    # Sem tags
    # detect = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTI1ODgmY3ZxPXI3MTg1b3EzbnI0MDQmZ3Z6cmZnbnpjPTIwMTUwNjA2MDAxOTQ4","pid":"F@0d805a8b7e8a20ae06a427821a663dae_e7185bd3ae404","width":300,"height":150,"tags":[]}],"usage":{"used":1,"remaining":99,"limit":100,"reset_time":1433550597,"reset_time_text":"Sat, 6 June 2015 00:29:57 +0000"},"operation_id":"65ea78fab63f4ec99fb3dd1a1f43cb61"}'
    # Uma tag
    # detect = JSON.parse '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTk2OTUmY3ZxPTY2cDY1NDQ3NjBzMTYmZ3Z6cmZnbnpjPTIwMTUwNjA1MDE0NzUz","pid":"F@0da7f39f3e72abe16a1af9685812c4ab_66c6544760f16","width":300,"height":150,"tags":[{"uids":[],"label":null,"confirmed":false,"manual":false,"width":18.0,"height":36.0,"yaw":24,"roll":6,"pitch":0,"attributes":{"face":{"value":"true","confidence":60}},"points":null,"similarities":null,"tid":"TEMP_F@0da7f39f3e72abe16a1af968009c005d_66c6544760f16_52.00_62.00_0_1","recognizable":true,"center":{"x":52.0,"y":62.0},"eye_left":{"x":54.0,"y":54.0,"confidence":52,"id":449},"eye_right":{"x":45.0,"y":51.33,"confidence":54,"id":450},"mouth_center":{"x":48.0,"y":72.67,"confidence":47,"id":615},"nose":{"x":48.67,"y":62.0,"confidence":54,"id":403}}]}],"usage":{"used":10,"remaining":90,"limit":100,"reset_time":1433474997,"reset_time_text":"Fri, 5 June 2015 03:29:57 +0000"},"operation_id":"75f8167817724037900c2614a9e4998d"}'
    # Varias tags
    # detect = JSON.parse '{"status":"success","photos":[{"url":"https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/p180x540/10256530_691954754174414_3884376225325975480_n.jpg?oh=fe957fa01553d0ba28612a04d915e74a&oe=55A8C1B1&__gda__=1436997505_83f78977f7487f9cd931f94d750b3159","pid":"F@0e98aa825ccca4d04c695bbe7231b30c_20b6dc66a738e","width":720,"height":540,"tags":[{"uids":[{"uid":"marcelo@Test2","confidence":49}],"label":null,"confirmed":false,"manual":false,"width":7.22,"height":9.63,"yaw":-27,"roll":0,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe009a00de_20b6dc66a738e_21.39_41.11_0_1","recognizable":true,"threshold":52,"center":{"x":21.39,"y":41.11},"eye_left":{"x":24.17,"y":38.7,"confidence":53,"id":449},"eye_right":{"x":20.69,"y":38.33,"confidence":52,"id":450},"mouth_center":{"x":22.5,"y":43.52,"confidence":25,"id":615},"nose":{"x":22.64,"y":41.48,"confidence":55,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":40}],"label":null,"confirmed":false,"manual":false,"width":6.39,"height":8.52,"yaw":-27,"roll":5,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe010100b8_20b6dc66a738e_35.69_34.07_0_1","recognizable":true,"threshold":52,"center":{"x":35.69,"y":34.07},"eye_left":{"x":38.33,"y":32.41,"confidence":52,"id":449},"eye_right":{"x":35.14,"y":32.22,"confidence":51,"id":450},"mouth_center":{"x":36.67,"y":36.48,"confidence":53,"id":615},"nose":{"x":36.94,"y":34.81,"confidence":56,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":47}],"label":null,"confirmed":false,"manual":false,"width":6.53,"height":8.7,"yaw":2,"roll":-5,"pitch":0,"attributes":{"face":{"value":"true","confidence":73}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe0164008b_20b6dc66a738e_49.44_25.74_0_1","recognizable":true,"threshold":52,"center":{"x":49.44,"y":25.74},"eye_left":{"x":50.83,"y":23.15,"confidence":54,"id":449},"eye_right":{"x":47.36,"y":23.7,"confidence":50,"id":450},"mouth_center":{"x":49.44,"y":28.15,"confidence":54,"id":615},"nose":{"x":49.31,"y":26.48,"confidence":57,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":100}],"label":null,"confirmed":true,"manual":false,"width":6.94,"height":9.26,"yaw":16,"roll":-8,"pitch":0,"attributes":{"face":{"value":"true","confidence":77}},"points":null,"similarities":null,"tid":"01d400af_20b6dc66a738e","recognizable":true,"threshold":52,"center":{"x":65,"y":32.41},"eye_left":{"x":65.97,"y":29.63,"confidence":53,"id":449},"eye_right":{"x":62.5,"y":30.19,"confidence":52,"id":450},"mouth_center":{"x":64.31,"y":35,"confidence":53,"id":615},"nose":{"x":64.31,"y":33.15,"confidence":58,"id":403}}]}],"usage":{"used":6,"remaining":94,"limit":100,"reset_time":1428388197,"reset_time_text":"Tue, 7 April 2015 06:29:57 +0000"},"operation_id":"0227947c12914f6793bdcec36ab33bb0"}'
    detect = face.faces_detect(:urls => url) unless url.blank?


    # seleciona tags detectadas
    # obs.: "first" foi usado pois o resultado de JsonPath para argumetos com ".." fica em um array
    tags = JsonPath.on(detect, "$.photos..tags").first
    @relatorio << [mensagem: 'Não foi possível detectar sua face!', erros:[tags: tags], detect: detect] if tags.blank?


    # Encontra qual tag detectata com maior confiança (confidence)
    # Caso existam mais de uma com o valor de qualidade maxima, apenas a primeira sera usada
    # c = confidences
    if !tags.blank?
      c = JsonPath.on(tags, "$..face..confidence")
      @relatorio << [mensagem: 'Não foi possível detectar sua face!', erros: [confidences: c], detect: detect] if c.blank?

      # define o valor mais alto entre as "confidence" das tags identificadas
      if c.is_a? Integer
        maximo = c
      elsif c.is_a? Array
        maximo = c.max
      end

      aprovada = maximo.to_i >= limite
      if aprovada
        c = c.index(c.max)
        tag = tags[c]

        # Encontra o tid nos dados da face encontrada acima
        tid = JsonPath.on(tag, "$.tid").first unless tag.blank?
      end unless c.blank? # não faça caso "c" esteja vazio
      @relatorio << [mensagem: 'Essa foto não ficou boa, que tentar novamente?', erros: [certeza: maximo, limite: limite], detect: detect] unless aprovada
    end

    # retorno
    tid

  end

  def cadastrar tid, id

    face = Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')

    namespace = 'userAce'
    uid = "#{id}@#{namespace}"

    # tagsSave = JSON.parse '{"status":"success","saved_tags":[{"tid":"009c005d_66c6544760f16","detected_tid":"TEMP_F@0da7f39f3e72abe16a1af968009c005d_66c6544760f16_52.00_62.00_0_1"}],"message":"Tag saved with uid: 1@userAce, label: ","operation_id":"622839020ebb4027ac848d315130bafc"}'
    tagsSave = face.tags_save(:uid => uid, :tids => tid)

    # verifica resposta de tagsSave
    if !JsonPath.on(tagsSave, '$.saved_tags').blank?
      # facesTrain = JSON.parse '{"status":"success","created":[{"uid":"1@userAce","training_set_size":1,"last_trained":1433557791,"training_in_progress":false}],"operation_id":"bdb679e7dc4a4df4aa1b51f7eb700972"}'
      facesTrain = face.faces_train(:uids => id, :namespace  => namespace)
    end

    @relatorio << [
        mensagem: 'Não foi possível salvar sua face!',
        erros: ['unchanged'],
        facesTrain: facesTrain
    ] unless JsonPath.on(facesTrain, '$.unchanged').blank?

    # TODO mostrar no retorno se foi "created" ou "updated", em caso de sucesso
    # retorno
    result = JsonPath.on(facesTrain, '$.created')
    result = JsonPath.on(facesTrain, '$.updated') if result.blank?
    result
  end





  # GET /reconher
  def recognizeTest

    #verifica os dados recebidos
    form = params['person']
    if !form.blank?
      file = form['file1'] # para upload
      url = form['url1'] # para url e base64
      uid = 'marcelo@Test2'
      # verifica imagem recebida, preferencialmente "url"
      if !url.blank?
        response = @face.faces_recognize(:uids => uid, :urls => url) unless url.blank?
      elsif !file.blank?
        response = @face.faces_recognize(:uids => uid, :file => file) unless file.blank?
      end
    end

    #verifica a resposta da análise da imagem, e pega seus dados "tags"
    if !response.blank?
      tags = response['photos'][0]['tags']
    else
      tags = @jsonGroup['photos'][0]['tags'] # dados de preenchimento
      response = @jsonGroup
    end

    @response = response # envia "response" para a view

    @faces = {}
    @style = {}

    tags.each_with_index   do |face, index|
      @faces[index] = {
          :eye_left     => {:title => "Left eye: X=#{face['eye_left']['x']}, Y=#{face['eye_left']['y']}, Confidence=#{face['eye_left']['confidence']}"},
          :eye_right    => {:title => "Left eye: X=#{face['eye_right']['x']}, Y=#{face['eye_right']['y']}, Confidence=#{face['eye_right']['confidence']}"},
          :mouth_center => {:title => "Left eye: X=#{face['mouth_center']['x']}, Y=#{face['mouth_center']['y']}, Confidence=#{face['mouth_center']['confidence']}"},
          :nose         => {:title => "Left eye: X=#{face['nose']['x']}, Y=#{face['nose']['y']}, Confidence=#{face['nose']['confidence']}"},
      }
      @faces[index][:confidence] = face['uids'][0]['confidence'] if !face['uids'][0].blank?

      @style[index] = "
          .eye_left#{index} {
              top: #{face['eye_left']['y']}%;
              left: #{face['eye_left']['x']}%;
          }
          .eye_right#{index} {
              top: #{face['eye_right']['y']}%;
              left: #{face['eye_right']['x']}%;
          }
          .mouth#{index} {
              top: #{face['mouth_center']['y']}%;
              left: #{face['mouth_center']['x']}%;
          }
          .nose#{index} {
              top: #{face['nose']['y']}%;
              left: #{face['nose']['x']}%;
          }
          .api_face#{index} {
              top: #{face['center']['y']}%;
              left: #{face['center']['x']}%;
              width: #{face['width']}%;
              height: #{face['height']}%;
              transform: rotate(#{face['roll']}deg) translate(-50%, -50%);
          }
      "
    end
  end

  # GET /detectar
  def detectTest
    #face = Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')
    #@tagsSave = face.tags_save(:uid => 'marcelo@Test2', :tids => @json['photos'][0]['tags'][0]['tid'])
    #@facesTrain = face.faces_train(:uids => 'marcelo', :namespace  => 'Test2')
    #@reconhecendo = face.faces_recognize(:uids => 'marcelo@Test2', :urls => 'https://scontent-gru.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/295925_299091690117203_1901965243_n.jpg?oh=5e9b40f8a84da49056f1bade75a5c2f5&oe=55A4F3DD')

    #verifica os dados recebidos
    form = params['person']
    if !form.blank?
      file = form['file1'] # para upload
      url = form['url1'] # para url e base64

      # verifica imagem recebida, preferencialmente "url"
      if !url.blank?
        response = @face.faces_detect(:urls => url) unless url.blank?
      elsif !file.blank?
        response = @face.faces_detect(:file => file) unless file.blank?
      end
    end

    #verifica a resposta da análise da imagem, e pega seus dados "tags"
    if !response.blank?
      tags = response['photos'][0]['tags']
    else
      tags = @jsonGroup['photos'][0]['tags'] # dados de preenchimento
      response = @jsonGroup
    end

    @response = response # envia "response" para a view

    @faces = {}
    @style = {}

    tags.each_with_index   do |face, index|
      @faces[index] = {
          :eye_left     => {:title => "Left eye: X=#{face['eye_left']['x']}, Y=#{face['eye_left']['y']}, Confidence=#{face['eye_left']['confidence']}"},
          :eye_right    => {:title => "Left eye: X=#{face['eye_right']['x']}, Y=#{face['eye_right']['y']}, Confidence=#{face['eye_right']['confidence']}"},
          :mouth_center => {:title => "Left eye: X=#{face['mouth_center']['x']}, Y=#{face['mouth_center']['y']}, Confidence=#{face['mouth_center']['confidence']}"},
          :nose         => {:title => "Left eye: X=#{face['nose']['x']}, Y=#{face['nose']['y']}, Confidence=#{face['nose']['confidence']}"}
      }

      @style[index] = "
          .eye_left#{index} {
              top: #{face['eye_left']['y']}%;
              left: #{face['eye_left']['x']}%;
          }
          .eye_right#{index} {
              top: #{face['eye_right']['y']}%;
              left: #{face['eye_right']['x']}%;
          }
          .mouth#{index} {
              top: #{face['mouth_center']['y']}%;
              left: #{face['mouth_center']['x']}%;
          }
          .nose#{index} {
              top: #{face['nose']['y']}%;
              left: #{face['nose']['x']}%;
          }
          .api_face#{index} {
              top: #{face['center']['y']}%;
              left: #{face['center']['x']}%;
              width: #{face['width']}%;
              height: #{face['height']}%;
              transform: rotate(#{face['roll']}deg) translate(-50%, -50%);
          }
      "
    end


  end

  private

  def face_conection
    @face = Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')
    @jsonMarcelo = JSON.parse('{"status":"success","photos":[{"url":"https://scontent-gru.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/295925_299091690117203_1901965243_n.jpg?oh=5e9b40f8a84da49056f1bade75a5c2f5\u0026oe=55A4F3DD","pid":"F@01df0c701995bd986cba45fc7b36174d_6d24271ca738e","width":552,"height":635,"tags":[{"uids":[{"uid":"marcelo@Test2","confidence":100}],"label":null,"confirmed":true,"manual":false,"width":27.54,"height":23.94,"yaw":0,"roll":9,"pitch":0,"attributes":{"face":{"value":"true","confidence":57}},"points":null,"similarities":null,"tid":"014400ee_6d24271ca738e","recognizable":true,"threshold":49,"center":{"x":58.7,"y":37.48},"eye_left":{"x":67.21,"y":32.44,"confidence":55,"id":449},"eye_right":{"x":52.72,"y":30.24,"confidence":54,"id":450},"mouth_center":{"x":55.62,"y":45.2,"confidence":14,"id":615},"nose":{"x":58.7,"y":39.84,"confidence":51,"id":403}}]}],"usage":{"used":4,"remaining":96,"limit":100,"reset_time":1428280197,"reset_time_text":"Mon, 6 April 2015 00:29:57 +0000"},"operation_id":"2c54e736be5e42928f0460c3794e4c3c"}')
    @jsonGroup = JSON.parse('{"status":"success","photos":[{"url":"https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/p180x540/10256530_691954754174414_3884376225325975480_n.jpg?oh=fe957fa01553d0ba28612a04d915e74a&oe=55A8C1B1&__gda__=1436997505_83f78977f7487f9cd931f94d750b3159","pid":"F@0e98aa825ccca4d04c695bbe7231b30c_20b6dc66a738e","width":720,"height":540,"tags":[{"uids":[{"uid":"marcelo@Test2","confidence":49}],"label":null,"confirmed":false,"manual":false,"width":7.22,"height":9.63,"yaw":-27,"roll":0,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe009a00de_20b6dc66a738e_21.39_41.11_0_1","recognizable":true,"threshold":52,"center":{"x":21.39,"y":41.11},"eye_left":{"x":24.17,"y":38.7,"confidence":53,"id":449},"eye_right":{"x":20.69,"y":38.33,"confidence":52,"id":450},"mouth_center":{"x":22.5,"y":43.52,"confidence":25,"id":615},"nose":{"x":22.64,"y":41.48,"confidence":55,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":40}],"label":null,"confirmed":false,"manual":false,"width":6.39,"height":8.52,"yaw":-27,"roll":5,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe010100b8_20b6dc66a738e_35.69_34.07_0_1","recognizable":true,"threshold":52,"center":{"x":35.69,"y":34.07},"eye_left":{"x":38.33,"y":32.41,"confidence":52,"id":449},"eye_right":{"x":35.14,"y":32.22,"confidence":51,"id":450},"mouth_center":{"x":36.67,"y":36.48,"confidence":53,"id":615},"nose":{"x":36.94,"y":34.81,"confidence":56,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":47}],"label":null,"confirmed":false,"manual":false,"width":6.53,"height":8.7,"yaw":2,"roll":-5,"pitch":0,"attributes":{"face":{"value":"true","confidence":73}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe0164008b_20b6dc66a738e_49.44_25.74_0_1","recognizable":true,"threshold":52,"center":{"x":49.44,"y":25.74},"eye_left":{"x":50.83,"y":23.15,"confidence":54,"id":449},"eye_right":{"x":47.36,"y":23.7,"confidence":50,"id":450},"mouth_center":{"x":49.44,"y":28.15,"confidence":54,"id":615},"nose":{"x":49.31,"y":26.48,"confidence":57,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":100}],"label":null,"confirmed":true,"manual":false,"width":6.94,"height":9.26,"yaw":16,"roll":-8,"pitch":0,"attributes":{"face":{"value":"true","confidence":77}},"points":null,"similarities":null,"tid":"01d400af_20b6dc66a738e","recognizable":true,"threshold":52,"center":{"x":65,"y":32.41},"eye_left":{"x":65.97,"y":29.63,"confidence":53,"id":449},"eye_right":{"x":62.5,"y":30.19,"confidence":52,"id":450},"mouth_center":{"x":64.31,"y":35,"confidence":53,"id":615},"nose":{"x":64.31,"y":33.15,"confidence":58,"id":403}}]}],"usage":{"used":6,"remaining":94,"limit":100,"reset_time":1428388197,"reset_time_text":"Tue, 7 April 2015 06:29:57 +0000"},"operation_id":"0227947c12914f6793bdcec36ab33bb0"}') #Group
  end
end
