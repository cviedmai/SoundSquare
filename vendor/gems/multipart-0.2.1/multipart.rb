# Multipart POST file upload for Net::HTTP::Post.
#
# By Leonardo Boiko <leoboiko@gmail.com>, public domain.
#
# Usage: see documentation for Net::HTTP::FileForPost and
# Net::HTTP::Post#set_multipart_data.

require 'net/http'
require 'stringio'

module Net
  class HTTP

    # When sending files via POST (rfc1867), the HTTP message has a
    # special content-type: multipart/form-data.  Its body includes
    # zero or more key/value parameters like in other POST messages,
    # plus one or more file upload parameters.  File upload parameters
    # are special:
    # 
    # - A single parameter may carry more than one file.  This
    #   technique is called multipart/mixed.
    #    
    # - Each _file_ (not parameter!) can include extra metadata: its
    #   filename and mimetype.
    #
    # This class models the file arguments used in
    # multipart/form-data.  See Net::HTTP::Post#set_multipart_data for
    # examples.
    #
    class FileForPost
      attr_accessor :filename, :mimetype, :shouldclose
      attr_reader :input

      # Arguments:
      #
      # filepath_or_io:: The file to upload; either the pathname to
      #                  open, or an IO object.  If it's a pathname,
      #                  it will be opened now and closed
      #                  automatically later.
      #
      # mimetype:: The content-type.  Per RFC defaults to
      #            'application/octet-stream', but I recommend setting
      #            it explicitly.
      #
      # filename:: The file name to send to the remote server.  If not
      #            supplied, will guess one based on the file's path.
      #            You can set it later with filename=.
      #
      def initialize(filepath_or_io,
                     mimetype='application/octet-stream',
                     filename=nil)
        @mimetype = mimetype
        @filename = nil

        if filepath_or_io.respond_to? :read
          @input = filepath_or_io
          @shouldclose = false # came opened

          if filepath_or_io.respond_to? :path
            @filename = File.basename(filepath_or_io.path)
          end

        else
          @input = File.open(filepath_or_io, 'rb')
          @shouldclose = true # I opened it
          @filename = File.basename(filepath_or_io)
        end

      end

      def read(*args)
        @input.read(*args)
      end

      def maybeclose
        @input.close if @shouldclose
      end
    end

    class Post

      # Similar to Net::HTTP::Post#set_form_data (in Ruby's stardard
      # library), but set up file upload parameters using the
      # appropriate HTTP/HTML Forms multipart format.
      #
      # *Arguments*
      #
      # files_params:: A hash of file upload parameters.  The keys are
      #                parameter names, and the values are
      #                Net::HTTP::FileForPost instances.  See that
      #                class documentation for more info about how
      #                POST file upload works.
      #
      # other_params:: A hash of {key => value} pairs for the regular
      #                POST parameters, just like in set_form_data.
      #                Don't mix set_form_data and set_multipart_data;
      #                they'll overwrite each other's work.
      #
      # boundary1, boundary2:: A couple of strings which doesn't occur
      #                        in your files.  Boundary2 is only
      #                        needed if you're using the
      #                        multipart/mixed technique.  The
      #                        defaults should be OK for most cases.
      #
      # *Examples*
      #
      # Simplest case (single-parameter single-file), complete:
      #
      #   require 'net/http'
      #   require 'rubygems'
      #   require 'multipart'
      #
      #   req = Net::HTTP::Post.new('/scripts/upload.rb')
      #   req.basic_auth('jack', 'inflamed sense of rejection')
      #
      #   file = Net::HTTP::FileForPost.new('/tmp/yourlife.txt', 'text/plain')
      #   req.set_multipart_data({:poem => file},
      #
      #                          {:author => 'jack',
      #                            :user_agent => 'soapfactory'})
      #
      #   res = Net::HTTP.new(url.host, url.port).start do |http|
      #     http.request(req)
      #   end
      #
      # Convoluted example:
      #
      #   pic1 = Net::HTTP::FileForPost.new('pic1.jpeg', 'image/jpeg')
      #   pic2 = Net::HTTP::FileForPost.new(pic2_io, 'image/jpeg')
      #   pic3 = Net::HTTP::FileForPost.new('pic3.png', 'image/png')
      #   pic1_t = Net::HTTP::FileForPost.new('pic1_thumb.jpeg', 'image/jpeg')
      #   pic2_t = Net::HTTP::FileForPost.new(pic2_t_io, 'image/jpeg')
      #   desc = Net::HTTP::FileForPost.new('desc.html', 'text/html',
      #                                      'index.html') # remote fname
      #
      #   req.set_multipart_data({:gallery_description => des,
      #                           :pictures => [pic1, pic2, pic3],
      #                           :thumbnails => [pic1_t, pic2_t]},
      #
      #                          {:gallery_name => 'mygallery',
      #                           :encoding => 'utf-8'})
      #
      def set_multipart_data(files_params,
                             other_params={},
                             boundary1="paranguaricutirimirruaru0xdeadbeef",
                             boundary2="paranguaricutirimirruaru0x20132")

        self.content_type = "multipart/form-data; boundary=\"#{boundary1}\""

        tmp = StringIO.new('r+b')

        # let's do the easy ones first
        other_params.each do |key,val|
          tmp.write "--#{boundary1}\r\n"
          tmp.write "content-disposition: form-data; name=\"#{key}\"\r\n"
          tmp.write "\r\n"
          tmp.write "#{val}\r\n"
        end

        # now handle the files...
        files_params.each do |name, file|
          tmp.write "\r\n--#{boundary1}\r\n"

          # no \r\n
          tmp.write "content-disposition: form-data; name=\"#{name}\""

          if not file.is_a? Enumerable
            # single-file multipart is different

            if file.filename
              # right in content-dispo line
              tmp.write "; filename=\"#{file.filename}\"\r\n"
            else
              tmp.write "\r\n"
            end

            tmp.write "Content-Type: #{file.mimetype}\r\n"
            tmp.write "Content-Transfer-Encoding: binary\r\n"
            tmp.write "\r\n"
            tmp.write(file.read())
            file.maybeclose
          else
            # multiple-file parameter (multipart/mixed)
            tmp.write "\r\n"
            tmp.write "Content-Type: multipart/mixed;"
            tmp.write " boundary=\"#{boundary2}\"\r\n"

            file.each do |f|
              tmp.write "\r\n--#{boundary2}\r\n"

              tmp.write "Content-disposition: attachment"
              if f.filename
                tmp.write "; filename=\"#{f.filename}\"\r\n"
              else
                tmp.write "\r\n"
              end

              tmp.write "Content-Type: #{f.mimetype}\r\n"
              tmp.write "Content-Transfer-Encoding: binary\r\n"
              tmp.write "\r\n"
              tmp.write(f.read())
              f.maybeclose
            end
            tmp.write "\r\n--#{boundary2}--\r\n"
          end
        end
        tmp.write "--#{boundary1}--\r\n"

        
        tmp.flush
        self.content_length = tmp.size
        self.body_stream = tmp
        self.body_stream.seek(0)
        nil
      end
    end
  end
end
