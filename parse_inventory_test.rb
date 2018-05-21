# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'hashie'

class Hash
  def deep_finder(key, object=self, found=[])
    if object.respond_to?(:key?) && object.key?(key)
      found << object[key]
    end
    if object.is_a? Enumerable
      found << object.collect { |*a| deep_finder(key, a.last) }
    end
    found
    # found.flatten.compact
  end
end

def search_hash(hash, key)
  return hash[key] if hash.assoc(key)
  hash.delete_if{|key, value| value.class != Hash}
  new_hash = Hash.new
  hash.each_value {|values| new_hash.merge!(values)}
  unless new_hash.empty?
    search_hash(new_hash, key)
  end
end

inventory_path = 'inventory/vagrant_nested'
inventory = YAML.load_file(inventory_path)
# puts inventory

inventory.extend Hashie::Extensions::DeepFind
hashie_hosts = inventory.deep_find_all('hosts').inject(:merge)
puts hashie_hosts

hosts = inventory['all']['hosts']
# puts hosts
# ansible_hosts = inventory.select { | key, value | key == "hosts" }
ansible_hosts = inventory.deep_finder('hosts')
# puts ansible_hosts

searched_hosts = search_hash(inventory, 'hosts')
# puts searched_hosts

hashie_hosts.each_with_index do |(host_name, host_vars), index|
  puts host_name
  puts host_vars
  puts index
end
