<!--
Copyright (C) 2016-2019 Jones Magloire @Joxit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
-->
<remove-image>
  <material-button waves-center="true" rounded="true" waves-color="#ddd" title="This will delete the image." if="{ !opts.multiDelete }">
    <i class="material-icons">delete</i>
  </material-button>
  <material-checkbox if="{ opts.multiDelete }" title="Select this tag to delete it."></material-checkbox>
  <script type="text/javascript">
    const self = this;

    this.on('updated', function() {
    });

    this.on('updated', function() {
      if (self.multiDelete == self.opts.multiDelete) {
        return;
      }
      if (this.tags['material-button']) {
        this.delete = this.tags['material-button'].root.onclick = function(ignoreError) {
          const name = self.opts.image.name;
          const tag = self.opts.image.tag;
          registryUI.taglist.go(name);
          if (!self.digest) {
            registryUI.showErrorCanNotReadContentDigest();
            return;
          }
          const oReq = new Http();
          oReq.addEventListener('loadend', function() {
            if (this.status == 200 || this.status == 202) {
              registryUI.taglist.display()
              registryUI.snackbar('Deleting ' + name + ':' + tag + ' image. Run `registry garbage-collect config.yml` on your registry');
            } else if (this.status == 404) {
              ignoreError || registryUI.errorSnackbar('Digest not found');
            } else {
              registryUI.snackbar(this.responseText);
            }
          });
          oReq.open('DELETE', registryUI.url() + '/v2/' + name + '/manifests/' + self.digest);
          oReq.setRequestHeader('Accept', 'application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json');
          oReq.addEventListener('error', function() {
            registryUI.errorSnackbar('An error occurred when deleting image. Check if your server accept DELETE methods Access-Control-Allow-Methods: [\'DELETE\'].');
          });
          oReq.send();
        };
      }

      if (this.tags['material-checkbox']) {
        if (!this.opts.multiDelete && this.tags['material-checkbox'].checked) {
          this.tags['material-checkbox'].toggle();
        }
        this.tags['material-checkbox'].on('toggle', function() {
          registryUI.taglist.instance.trigger('toggle-remove-image', this.checked);
        });
      }
      self.multiDelete = self.opts.multiDelete;
    });

    opts.image.one('content-digest', function(digest) {
      self.digest = digest;
    });
    opts.image.trigger('get-content-digest');
  </script>
</remove-image>
