package simsimSa.apple.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import simsimSa.apple.model.User;

@Repository
public interface UserRepository extends JpaRepository<User, String> {
    // JpaRepository가 기본 CRUD 메서드들을 자동으로 제공합니다:
    // save(User user)
    // findById(String id)
    // findAll()
    // deleteById(String id)
    // 등등...
} 