function fruit_disease_detection_gui

    %GUI bileşenlerini oluşturdum.     
    f = figure('Name', 'Fruit Disease Detection', 'NumberTitle', 'off');
    ax = axes(f);
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Load Image', ...
        'Position', [20 20 100 20], 'Callback', @load_image_callback, ...
        'BackgroundColor', [0.678 0.847 0.902]);

    %Load image butonuna tıklandığında yapılacak işlemler için fonksiyon
    function load_image_callback(~, ~)
        disp("***********");
        %Butona her basıldığında önceki görüntüyü temizledim.
        cla(ax);

        %Dosyadan görüntü seçilmesi için dosya işlemlerini yürüttüm.
        [file_name, file_path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
        if file_name == 0
            return;
        end
        fruit = imread(fullfile(file_path, file_name));
        
        %Kenar tespit yöntemi için görüntüyü gri tonlamalı hale getirdim.
        gray_fruit = rgb2gray(fruit);
        
        % Canny algoritmasını kullanarak kenar tespiti yaptım.
        edge_fruit = edge(gray_fruit, 'Canny', 0.1);
        
        %Yarıçapı 3 olan disk şeklinde bir yapısal eleman oluşturdum.
        se = strel('disk', 3);
        %Yapısal elemanı kullanarak görüntünün kenarlarını genişlettim.
        dilated_edges = imdilate(edge_fruit, se);
        
        % Görüntüyü açıklıkla aydınlattım.
        img_adjusted = imadjust(gray_fruit);
        
        % Kenarları kullanarak hastalıklı bölgeleri tespit ettim.
        diseased_areas = img_adjusted;
        diseased_areas(dilated_edges) = 255;
        
        % Renk eşiği değerlerini tanımladım.
        hue_low = 0.02;
        hue_high = 0.08;
        saturation_low = 0.2;
        saturation_high = 1;
        value_low = 0.2;
        value_high = 1;
        
        % RGB görüntüsünü HSV renk uzayına dönüştürdüm.
        hsv_fruit = rgb2hsv(fruit);
        
        % Renk eşik değerlerine dayalı olarak meyve için binary maske
        % oluşturdum.
        disease_mask = (hsv_fruit(:,:,1) >= hue_low) & (hsv_fruit(:,:,1) <= hue_high) & ...
            (hsv_fruit(:,:,2) >= saturation_low) & (hsv_fruit(:,:,2) <= saturation_high) & ...
            (hsv_fruit(:,:,3) >= value_low) & (hsv_fruit(:,:,3) <= value_high);
        
        % Gürültüyü gidermek için morfolojik işlemleri uyguladım.
        se = strel('disk', 5);
        cleaned_mask = imclose(imopen(disease_mask,se), se);
        
        % Hastalıklı alan yüzdesini hesapladım.
        diseased_pixels = sum(cleaned_mask(:));
        total_pixels = numel(cleaned_mask);
        disease_percent = diseased_pixels / total_pixels * 100;
        
        % Binary maskeyi meyve resminin üzerine yerleştirdim.
        imshow(fruit, 'Parent', ax);
        hold on;
        h = imshow(repmat(uint8(cleaned_mask), [1,1,3]), 'Parent', ax);
        set(h, 'AlphaData', 0.3);
        
        % Binary maskeye göre meyvenin hastalıklı mı yoksa sağlıklı mı
        % olduğunu belirledim.
        if any(cleaned_mask(:)) 
            result = sprintf('The fruit is diseased. \nDisease area: %.2f%%', disease_percent);
            
            % Ara adımları figure üzerine yerleştirdim.
            figure('Name','Intermediate Steps');
            subplot(2,3,1);
            imshow(fruit);title('Original Image');
            subplot(2,3,2); 
            imshow(gray_fruit); title('Grayscale Image');
            subplot(2,3,3); 
            imshow(diseased_areas); title('Edge Detection');
            subplot(2,3,4); 
            imshow(hsv_fruit); title('HSV Image');
            subplot(2,3,5); 
            imshow(disease_mask); title('Disease Mask');
            subplot(2,3,6); 
            imshow(cleaned_mask); title('Cleaned Mask');

            % Hastalıklı ve temizlenmiş piksellerin sayısını buldum.
            disease_pixels = nnz(disease_mask);
            cleaned_pixels = nnz(cleaned_mask);

            % Hastalıklı ve temizlenmiş piksellerin oranlarını hesapladım.
            disease_ratio = disease_pixels / numel(disease_mask);
            cleaned_ratio = cleaned_pixels / numel(cleaned_mask);
            
            disp(['Disease Ratio: ', num2str(disease_ratio)]);
            disp(['Cleaned Ratio: ', num2str(cleaned_ratio)]);

        else
            % Ara adımları figure üzerine yerleştirdim.
            figure('Name','Intermediate Steps');
            subplot(2,3,1);
            imshow(fruit);title('Original Image');
            subplot(2,3,2); 
            imshow(gray_fruit); title('Grayscale Image');
            subplot(2,3,3); 
            imshow(diseased_areas); title('Edge Detection');
            subplot(2,3,4); 
            imshow(hsv_fruit); title('HSV Image');
            subplot(2,3,5); 
            imshow(disease_mask); title('Disease Mask');
            subplot(2,3,6); 
            imshow(cleaned_mask); title('Cleaned Mask');

            % Hastalıklı ve temizlenmiş piksellerin sayısını buldum.
            disease_pixels = nnz(disease_mask);
            cleaned_pixels = nnz(cleaned_mask);
            
            % Hastalıklı ve temizlenmiş piksellerin oranlarını hesapladım.
            disease_ratio = disease_pixels / numel(disease_mask);
            cleaned_ratio = cleaned_pixels / numel(cleaned_mask);
            
            disp(['Disease Ratio: ', num2str(disease_ratio)]);
            disp(['Cleaned Ratio: ', num2str(cleaned_ratio)]);
            
            % Mesaj kutusunda sonucu görüntülemek için sorgu oluşturdum.
            if disease_ratio > 0.1
                result = 'The fruit is diseased';
            else
                result = 'The fruit is healthy';
            end
              
        end
            msgbox(result); 
        end
end