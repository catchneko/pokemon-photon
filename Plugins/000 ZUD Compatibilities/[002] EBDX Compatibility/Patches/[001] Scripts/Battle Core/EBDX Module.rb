#===============================================================================
#  Main Utility Module for Elite Battle: DX
#-------------------------------------------------------------------------------
#  used to store and manipulate all of the configurable data and much more
#===============================================================================
if Settings::EBDX_COMPAT  
  module EliteBattle
    def self.get_vector(key, cond = nil)
      if [:MAIN, :BATTLER].include?(key)
        case key
        when :MAIN
          return @vectors[:DYNAMAX].clone if @vectors.has_key?(:DYNAMAX) && cond.respond_to?(:dynamaxactive?) && cond.dynamaxactive?
          return @vectors[:QUINTE].clone if @vectors.has_key?(:QUINTE) && Settings::EMBS_COMPAT && cond.respond_to?(:quintebattle?) && cond.quintebattle?
          return @vectors[:QUADRU].clone if @vectors.has_key?(:QUADRU) && Settings::EMBS_COMPAT && cond.respond_to?(:quadrubattle?) && cond.quadrubattle?
          return @vectors[:TRIPLE].clone if @vectors.has_key?(:TRIPLE) && cond.respond_to?(:triplebattle?) && cond.triplebattle?
          return @vectors[:DOUBLE].clone if @vectors.has_key?(:DOUBLE) && cond.respond_to?(:doublebattle?) && cond.doublebattle?
          return @vectors[:SINGLE].clone if @vectors.has_key?(:SINGLE)
        when :BATTLER
          return cond ? @vectors[:PLAYER].clone : @vectors[:ENEMY].clone if @vectors.has_key?(:PLAYER, :ENEMY)
        end
      end
      array = [102, 408, 32, 342, 1, 1]
      array+= [1, 1, 1, 1] if Settings::EMBS_COMPAT
      return array if !@vectors.has_key?(key)
      return @vectors[key].clone
    end
  end
end