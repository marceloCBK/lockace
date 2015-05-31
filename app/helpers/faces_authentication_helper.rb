module FacesAuthenticationHelper
  # before_action :static_images

  def reconhecer
    @test = "ok!!"
  end

  # GET /reconher
  def recognize

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
  def detect
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

  def static_images
    @face = Face.get_client(:api_key => '0da8aecb5c5742d5828dd1f3dcb803e3', :api_secret => 'f5abf82e3c30437da4a1493570b2eed0')
    @imgMarcelo = 'https://scontent-gru.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/295925_299091690117203_1901965243_n.jpg?oh=5e9b40f8a84da49056f1bade75a5c2f5&oe=55A4F3DD'
    @imgIsis = 'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p160x160/10526150_395052647317640_2767783111252648398_n.jpg?oh=ded6fc1c7909cc2b955fa83d7be22756&oe=55A8178C&__gda__=1436219185_b7b580debb24f042f627bc87bd9422ab'
    @imgGrpup = 'https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/p180x540/10256530_691954754174414_3884376225325975480_n.jpg?oh=fe957fa01553d0ba28612a04d915e74a&oe=55A8C1B1&__gda__=1436997505_83f78977f7487f9cd931f94d750b3159'
    @jsonMarcelo = JSON.parse('{"status":"success","photos":[{"url":"https://scontent-gru.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/295925_299091690117203_1901965243_n.jpg?oh=5e9b40f8a84da49056f1bade75a5c2f5\u0026oe=55A4F3DD","pid":"F@01df0c701995bd986cba45fc7b36174d_6d24271ca738e","width":552,"height":635,"tags":[{"uids":[{"uid":"marcelo@Test2","confidence":100}],"label":null,"confirmed":true,"manual":false,"width":27.54,"height":23.94,"yaw":0,"roll":9,"pitch":0,"attributes":{"face":{"value":"true","confidence":57}},"points":null,"similarities":null,"tid":"014400ee_6d24271ca738e","recognizable":true,"threshold":49,"center":{"x":58.7,"y":37.48},"eye_left":{"x":67.21,"y":32.44,"confidence":55,"id":449},"eye_right":{"x":52.72,"y":30.24,"confidence":54,"id":450},"mouth_center":{"x":55.62,"y":45.2,"confidence":14,"id":615},"nose":{"x":58.7,"y":39.84,"confidence":51,"id":403}}]}],"usage":{"used":4,"remaining":96,"limit":100,"reset_time":1428280197,"reset_time_text":"Mon, 6 April 2015 00:29:57 +0000"},"operation_id":"2c54e736be5e42928f0460c3794e4c3c"}')

    @jsonGroup = JSON.parse('{"status":"success","photos":[{"url":"https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/p180x540/10256530_691954754174414_3884376225325975480_n.jpg?oh=fe957fa01553d0ba28612a04d915e74a&oe=55A8C1B1&__gda__=1436997505_83f78977f7487f9cd931f94d750b3159","pid":"F@0e98aa825ccca4d04c695bbe7231b30c_20b6dc66a738e","width":720,"height":540,"tags":[{"uids":[{"uid":"marcelo@Test2","confidence":49}],"label":null,"confirmed":false,"manual":false,"width":7.22,"height":9.63,"yaw":-27,"roll":0,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe009a00de_20b6dc66a738e_21.39_41.11_0_1","recognizable":true,"threshold":52,"center":{"x":21.39,"y":41.11},"eye_left":{"x":24.17,"y":38.7,"confidence":53,"id":449},"eye_right":{"x":20.69,"y":38.33,"confidence":52,"id":450},"mouth_center":{"x":22.5,"y":43.52,"confidence":25,"id":615},"nose":{"x":22.64,"y":41.48,"confidence":55,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":40}],"label":null,"confirmed":false,"manual":false,"width":6.39,"height":8.52,"yaw":-27,"roll":5,"pitch":0,"attributes":{"face":{"value":"true","confidence":69}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe010100b8_20b6dc66a738e_35.69_34.07_0_1","recognizable":true,"threshold":52,"center":{"x":35.69,"y":34.07},"eye_left":{"x":38.33,"y":32.41,"confidence":52,"id":449},"eye_right":{"x":35.14,"y":32.22,"confidence":51,"id":450},"mouth_center":{"x":36.67,"y":36.48,"confidence":53,"id":615},"nose":{"x":36.94,"y":34.81,"confidence":56,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":47}],"label":null,"confirmed":false,"manual":false,"width":6.53,"height":8.7,"yaw":2,"roll":-5,"pitch":0,"attributes":{"face":{"value":"true","confidence":73}},"points":null,"similarities":null,"tid":"TEMP_F@0e98aa825ccca4d04c695bbe0164008b_20b6dc66a738e_49.44_25.74_0_1","recognizable":true,"threshold":52,"center":{"x":49.44,"y":25.74},"eye_left":{"x":50.83,"y":23.15,"confidence":54,"id":449},"eye_right":{"x":47.36,"y":23.7,"confidence":50,"id":450},"mouth_center":{"x":49.44,"y":28.15,"confidence":54,"id":615},"nose":{"x":49.31,"y":26.48,"confidence":57,"id":403}},{"uids":[{"uid":"marcelo@Test2","confidence":100}],"label":null,"confirmed":true,"manual":false,"width":6.94,"height":9.26,"yaw":16,"roll":-8,"pitch":0,"attributes":{"face":{"value":"true","confidence":77}},"points":null,"similarities":null,"tid":"01d400af_20b6dc66a738e","recognizable":true,"threshold":52,"center":{"x":65,"y":32.41},"eye_left":{"x":65.97,"y":29.63,"confidence":53,"id":449},"eye_right":{"x":62.5,"y":30.19,"confidence":52,"id":450},"mouth_center":{"x":64.31,"y":35,"confidence":53,"id":615},"nose":{"x":64.31,"y":33.15,"confidence":58,"id":403}}]}],"usage":{"used":6,"remaining":94,"limit":100,"reset_time":1428388197,"reset_time_text":"Tue, 7 April 2015 06:29:57 +0000"},"operation_id":"0227947c12914f6793bdcec36ab33bb0"}') #Group
  end
end
