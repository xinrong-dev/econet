module Sharepoint

  module SharepointRestfulApi

    def sharepoint_access_token
      config = YAML.load_file(File.join(__dir__, '../../config/sharepoint.yml'))
      url = URI('https://accounts.accesscontrol.windows.net/' + config['tenant_id'] + '/tokens/OAuth/2')

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/x-www-form-urlencoded'      
      request.body = 'grant_type=client_credentials' +
        '&client_id=' + config['client_id'] + '@' + config['tenant_id'] +
        '&client_secret=' + config['client_secret'] +
        '&resource=' + config['resource_id'] + '/' + config['site_url'] + '@' + config['tenant_id']
      response = https.request(request)
      parsed = JSON.parse(response.read_body)

      return parsed['access_token']
    end

    def sharepoint_create_folder(access_token, folder_name)
      config = YAML.load_file(File.join(__dir__, '../../config/sharepoint.yml'))
      url = URI('https://' + config['site_url'] + '/_api/web/folders')

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json;odata=verbose'
      request['Content-Type'] = 'application/json;odata=verbose'
      request['Authorization'] = 'Bearer ' + access_token
      request.body = "{\"__metadata\": {\"type\": \"SP.Folder\"},\"ServerRelativeUrl\": \"/Shared Documents/□②事務/◎①見積・発注/" + folder_name + "\"}"
      https.request(request)
    end

    def sharepoint_upload_file(access_token, folder_name, file_name)
      config = YAML.load_file(File.join(__dir__, '../../config/sharepoint.yml'))
      url = URI.parse(URI.escape('https://' + config['site_url'] + "/_api/web/GetFolderByServerRelativeUrl('/Shared Documents/□②事務/◎①見積・発注/" + folder_name + "')/Files/Add(url='" + file_name + "', overwrite=true)"))

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json;odata=verbose'
      request['Authorization'] = 'Bearer ' + access_token
      request['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      
      file = File.open(File.join(__dir__, '../../assets/sharepoint/sheet.xlsx'), 'rb')
      request.body = file.read

      https.request(request)
    end

  end

end
